# frozen_string_literal: true

# Represents a file uploaded by the user and stored against the original claim ()ET1) / response (ET3)
class UploadedFile < ApplicationRecord
  has_one_attached :file
  include StoredFileDownload
end
