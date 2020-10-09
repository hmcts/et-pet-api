# frozen_string_literal: true

# Represents a file uploaded by the user and stored against the original claim ()ET1) / response (ET3)
class UploadedFile < ApplicationRecord
  has_one_attached :file
  include StoredFileDownload
  include StoredFileBase64Import

  scope :not_hidden, -> { where('filename NOT LIKE ? AND filename NOT LIKE ? AND filename NOT LIKE ?', 'acas_%', 'et1_%.txt', 'et1a_%.txt') }
  scope :not_pdf, -> { where('filename NOT LIKE ?', 'et1_%.pdf') }
  scope :et1_pdf, -> { where('filename LIKE ?', 'et1_%.pdf') }
  scope :et1_rtf, -> { where('filename LIKE ?', 'et1_%.rtf') }
  scope :et1_csv, -> { where('filename LIKE ?', 'et1a_%.csv') }
end
