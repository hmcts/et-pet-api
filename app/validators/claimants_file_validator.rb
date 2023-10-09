# frozen_string_literal: true

class ClaimantsFileValidator < ActiveModel::EachValidator
  CORRECT_COLUMNS = ['Title', 'First name', 'Last name', 'Date of birth', 'Building number or name', 'Street', 'Town/city', 'County', 'Postcode'].freeze

  def validate_each(record, attribute, value)
    timings = {}
    direct_upload_service = create_direct_upload_service
    validate_and_measure_time(attribute, record, value, direct_upload_service: direct_upload_service, timings: timings)
    total = timings.values.sum
    Rails.logger.tagged("ClaimantsFileValidator") do |l|
      l.info("File #{value} validated from direct upload container in #{total}ms (Exists check: #{timings[:exists]}ms, Download: #{timings[:download]}ms)")
    end
  end

  private

  attr_accessor :timings, :logger, :direct_upload_service

  def validate_and_measure_time(attribute, record, value, direct_upload_service:, timings:)
    return unless validate_file_exists(record, value, direct_upload_service: direct_upload_service, timings: timings)

    file = file_for(record, attribute, value, direct_upload_service: direct_upload_service, timings: timings)
    return unless validate_header(file, record)

    validate_file(file, record, attribute)
  end

  def validate_file_exists(record, value, direct_upload_service:, timings:)
    exists = nil
    timings[:exists] = measure do
      exists = direct_upload_service.exist?(value)
    end
    return true if exists

    record.errors.add(:base, :missing_file, **extra_error_details(record))
    false
  end

  def validate_header(file, record)
    first_row = CSV.parse_line(file.readline)
    file.rewind
    return true if (CORRECT_COLUMNS - first_row).empty?

    record.errors.add(:base, :invalid_columns, **extra_error_details(record))
    false
  rescue EOFError
    record.errors.add(:base, :empty_file, **extra_error_details(record))
    false
  end

  def file_for(_record, _attribute, value, direct_upload_service:, timings:)
    tempfile = Tempfile.new
    tempfile.binmode
    timings[:download] = measure do
      direct_upload_service.download(value) { |chunk| tempfile.write(chunk) }
    end
    tempfile.rewind
    tempfile
  end

  def create_direct_upload_service
    config = Rails.configuration.active_storage
    ActiveStorage::Service.configure :"#{config.service}_direct_upload", config.service_configurations
  end

  def measure(&block)
    Benchmark.ms(&block).round(1)
  end

  def validate_file(file, record, attribute)
    rows = CSV.new(file, headers: true).lazy
    @validation_line_count = 0
    claimants_file = ClaimantsFile.new
    rows.each_with_index do |row, index|
      @validation_line_count += 1
      validate_row row, record, attribute, claimants_file, index
    end
    if options[:save_line_count]
      record.send(options[:save_line_count], @validation_line_count)
    end
  end

  def validate_row(row, record, attribute, claimants_file, row_index)
    claimants_file.attributes = normalize_row(row)
    return if claimants_file.valid?

    generate_errors(attribute, claimants_file, record, row_index)
  end

  def normalize_row(row) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    { title: row['Title']&.strip&.downcase&.capitalize,
      first_name: row['First name']&.strip,
      last_name: row['Last name']&.strip,
      date_of_birth: row['Date of birth']&.strip,
      building: row['Building number or name']&.strip,
      street: row['Street']&.strip,
      locality: row['Town/city']&.strip,
      county: row['County']&.strip,
      post_code: row['Postcode']&.strip }
  end

  def generate_errors(attribute, claimants_file, record, row_index)
    claimants_file.errors.details.each_pair do |attr, row_errors|
      messages = claimants_file.errors.messages[attr]
      row_errors.each_with_index do |error, idx|
        record.errors.add(:"#{attribute}[#{row_index}].#{attr}", messages[idx], **error.merge(extra_error_details(record)))
      end
    end
  end

  def extra_error_details(record)
    return {} unless record.is_a?(BaseCommand)

    {
      uuid: record.uuid,
      command: record.command_name
    }
  end

  class ClaimantsFile
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations::Callbacks

    TITLES      = ['Mr', 'Mrs', 'Miss', 'Ms'].freeze
    NAME_LENGTH = 100
    POSTCODE_LENGTH = 8

    attribute :title, :string
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :date_of_birth, :date
    attribute :building, :string
    attribute :street, :string
    attribute :locality, :string
    attribute :county, :string
    attribute :post_code, :string

    validates :title, inclusion: { in: TITLES }, allow_blank: true
    validates :first_name, :last_name, length: { maximum: NAME_LENGTH }, presence: true
    validates :post_code, post_code: true, length: { maximum: POSTCODE_LENGTH }
    validates :street, :locality, length: { maximum: 50 }
    validate :illegal_birth_year, unless: :date_of_birth_blank?
    validate :age_between_range, unless: :date_of_birth_blank?

    private

    def illegal_birth_year
      errors.add :date_of_birth, :invalid if date_of_birth.nil? || date_of_birth.year < 1000
    end

    def age_between_range
      return if date_of_birth.nil?

      errors.add :date_of_birth, :date_range unless (date_of_birth > 100.years.ago) && (date_of_birth < 10.years.ago)
    end

    def date_of_birth_blank?
      date_of_birth.blank? && @attributes.values_before_type_cast['date_of_birth'].blank?
    end
  end
end
