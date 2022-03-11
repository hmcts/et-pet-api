class ValidateClaimantsFileCommand < BaseCommand
  attribute :filename, :string
  attribute :checksum, :string
  attribute :data_from_key, :string
  attribute :data_url, :string

  validates :data_from_key, claimants_file: { save_line_count: :validation_line_count }
  def apply(root_object, meta: {})
    root_object[:line_count] = @validation_line_count
  end

  private

  def validation_line_count(line_count)
    @validation_line_count = line_count
  end
end
