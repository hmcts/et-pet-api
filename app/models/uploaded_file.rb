# frozen_string_literal: true

# Represents a file uploaded by the user and stored against the original claim ()ET1) / response (ET3)
class UploadedFile < ApplicationRecord
  has_one_attached :file
  include StoredFileDownload
  include StoredFileBase64Import

  has_many :response_uploaded_files, dependent: :destroy

  scope :not_hidden, -> { where('filename NOT LIKE ? AND filename NOT LIKE ? AND filename NOT LIKE ? AND filename NOT ILIKE ? AND filename NOT ILIKE ?', 'acas_%', 'et1_%.txt', 'et1a_%.txt', 'et1_%.rtf', 'et1_%_trimmed.pdf') }
  scope :not_pdf, -> { where('filename NOT LIKE ?', 'et1_%.pdf') }
  scope :et1_pdf, -> { where('filename LIKE ? AND filename NOT LIKE ?', 'et1_%.pdf', 'et1_%_trimmed.pdf') }
  scope :et1_rtf, -> { not_hidden.where('filename ILIKE ?', '%.rtf') }
  scope :et1_csv, -> { where('filename LIKE ?', 'et1a_%.csv') }
  scope :et3_pdf, -> { where('filename LIKE ?', 'et3_atos_export.pdf') }
  scope :et3_input_rtf, -> { where('filename LIKE ?', 'additional_information.rtf') }
  scope :et3_output_rtf, -> { where('filename LIKE ?', 'et3_atos_export.rtf') }

  def to_be_imported?
    import_from_key.present? || import_file_url.present?
  end
end
