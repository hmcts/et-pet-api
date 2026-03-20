class ValidateAdditionalInformationFileCommand < BaseCommand
  attribute :filename, :string
  attribute :checksum, :string
  attribute :data_from_key, :string
  attribute :data_url, :string

  validate :validate_file_exists
  validates :data_from_key, file_not_password_protected: true, if: :direct_uploaded_file_exists?

  def apply(root_object, meta: {}) # rubocop:disable Lint/UnusedMethodArgument
    root_object[:line_count] = nil
  end

  private

  def validate_file_exists
    return if data_from_key.blank? || direct_uploaded_file_exists?

    errors.add(:base, :missing_file, uuid: uuid, command: command_name)
  end

  def direct_uploaded_file_exists?
    return @direct_uploaded_file_exists if defined?(@direct_uploaded_file_exists)

    @direct_uploaded_file_exists = DirectUploadedFile.with_blob_key(data_from_key).exists?
  end
end
