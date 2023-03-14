# frozen_string_literal: true

# Represents a file uploaded by the user and stored against the original claim ()ET1) / response (ET3)
class UploadedFile < ApplicationRecord
  has_one_attached :file
  include StoredFileDownload
  include StoredFileBase64Import

  has_many :response_uploaded_files, dependent: :destroy

  scope :not_pdf, -> { where('filename NOT LIKE ?', 'et1_%.pdf') }
  scope :et1_pdf, -> { where('filename LIKE ? AND filename NOT LIKE ?', 'et1_%.pdf', 'et1_%_trimmed.pdf') }
  scope :et1_claim_details, -> { user_file_scope.where('filename ILIKE ?', '%.rtf') }
  scope :et1_csv, -> { user_file_scope.where('filename ILIKE ?', '%.csv') }
  scope :et3_pdf, -> { system_file_scope.where('filename LIKE ?', 'et3_atos_export.pdf') }
  scope :et3_input_additional_info, -> { where('filename ILIKE ?', 'additional_information.rtf') }
  scope :et3_output_additional_info, -> { where('filename ILIKE ?', 'et3_atos_export.rtf') }
  enum file_scope: { user: 'user', system: 'system' }, _suffix: true

  def to_be_imported?
    import_from_key.present? || import_file_url.present?
  end

  delegate :content_type, to: :file
end
