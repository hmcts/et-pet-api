class ResponseUploadedFile < ApplicationRecord
  belongs_to :response
  belongs_to :uploaded_file
end
