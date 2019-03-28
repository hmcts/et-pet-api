class ValidateClaimantsFileCommand < BaseCommand
  attribute :filename, :string
  attribute :checksum, :string
  attribute :data_from_key, :string
  attribute :data_url, :string

  validates :data_from_key, claimants_file: true
  def apply(*)
    raise "This command is a validator - so apply should not be called - only .valid?"
  end
end
