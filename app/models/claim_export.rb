class ClaimExport < ApplicationRecord
  belongs_to :claim
  belongs_to :pdf_file, class_name: 'UploadedFile', optional: true
end
