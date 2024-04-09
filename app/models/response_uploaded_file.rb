class ResponseUploadedFile < ApplicationRecord
  belongs_to :response
  belongs_to :uploaded_file, dependent: :destroy
end
