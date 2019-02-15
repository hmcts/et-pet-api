require 'csv'
class ClaimClaimantsFileImporterService
  ADDRESS_COLUMNS = ['building', 'street', 'locality', 'county', 'post_code'].freeze
  CLAIMANT_COLUMNS = ['title', 'first_name', 'last_name', 'date_of_birth'].freeze

  attr_reader :errors
  def initialize(claim, autosave: true)
    self.claim = claim
    self.autosave = autosave
    self.errors = []
  end

  def call
    raise "The claim must be saved with no changes before this importer can be used" unless claim.persisted? && claim.changes.empty?
    import_claimants uploaded_file: csv_file
  end

  private

  def csv_file
    claim.claimants_csv_file
  end

  def import_claimants(uploaded_file:)
    tempfile = Tempfile.new
    uploaded_file.download_blob_to(tempfile.path)
    utf8_tempfile = force_utf8_file(tempfile)
    ActiveRecord::Base.transaction do
      import_claimants_from_file(file: utf8_tempfile.path)
      claim.save! if autosave
    end
  end

  def force_utf8_file(file)
    block_size = 1024
    tempfile = Tempfile.new
    loop do
      chunk = file.read(block_size)
      break if chunk.nil?
      tempfile.write chunk.encode('utf-8', invalid: :replace, undef: :replace)
    end
    tempfile.tap(&:close)
  end

  def import_claimants_from_file(file:)
    to_import = OpenStruct.new(claimants: [], addresses: []).freeze
    CSV.foreach(file, headers: true) do |row|
      claimant = build_claimant_from row
      errors << claimant.errors && next unless claimant.valid?
      append_to_import(claimant, to_import)
    end
    raise ActiveRecord::Rollback if errors.present?
    insert_records(to_import)
  end

  def insert_records(to_import)
    insert_addresses(to_import)
    insert_claimants(to_import)
  end

  def append_to_import(claimant, to_import)
    to_import.claimants << claimant_values(claimant)
    to_import.addresses << address_values(claimant)
  end

  def build_claimant_from(row)
    Claimant.new title: row["Title"], first_name: row['First name'].try(:downcase),
                 last_name: row['Last name'].try(:downcase), date_of_birth: row['Date of birth'],
                 address_attributes: address_from_row(row)
  end

  def address_from_row(row)
    {
      building: row['Building number or name'].try(:downcase),
      street: row['Street'].try(:downcase),
      locality: row['Town/city'].try(:downcase),
      county: row['County'].try(:downcase),
      post_code: row['Postcode'].try(:downcase)
    }
  end

  def claimant_values(claimant)
    created_at = Time.now.utc
    claimant.attributes.slice(*CLAIMANT_COLUMNS).values + [created_at, created_at]
  end

  def address_values(claimant)
    created_at = Time.now.utc
    claimant.address.attributes.slice(*ADDRESS_COLUMNS).values + [created_at, created_at]
  end

  def insert_addresses(to_import)
    insert = insert_arel_for to_import.addresses, table: Address.arel_table,
                                                  columns: ADDRESS_COLUMNS + ['created_at', 'updated_at']
    result = Address.connection.execute insert.to_sql + " RETURNING \"id\"", "Addresses Bulk Insert"
    ids = result.field_values('id')
    to_import.claimants.map!.with_index do |claimant, idx|
      claimant << ids[idx]
    end
  end

  def insert_arel_for(values, table:, columns:)
    insert = Arel::Nodes::InsertStatement.new
    insert.relation = table
    insert.columns = columns.map { |column| insert.relation[column] }
    insert.values = Arel::Nodes::ValuesList.new(values)
    insert
  end

  def insert_claimants(to_import)
    insert = insert_arel_for to_import.claimants, table: Claimant.arel_table,
                                                  columns: CLAIMANT_COLUMNS + ['created_at', 'updated_at', 'address_id']
    result = Address.connection.execute insert.to_sql + " RETURNING \"id\"", "Claimants Bulk Insert"
    insert_claim_claimants(result.field_values('id'))
  end

  def insert_claim_claimants(claimant_ids)
    claim_id = claim.id
    claim_claimant = claimant_ids.map { |id| [claim_id, id] }
    insert = insert_arel_for claim_claimant, table: claim.claim_claimants.arel_table,
                                             columns: ['claim_id', 'claimant_id']
    Address.connection.execute insert.to_sql, "Claim - Claimants Bulk Insert"
    reset_claim_associations
  end

  def reset_claim_associations
    claim.claim_claimants.reset
    claim.secondary_claimants.reset
  end

  attr_writer :errors
  attr_accessor :claim, :autosave
end
