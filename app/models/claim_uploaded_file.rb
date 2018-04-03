class ClaimUploadedFile < ApplicationRecord
  belongs_to :claim
  belongs_to :uploaded_file
end
