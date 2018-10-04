# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class ClaimUploadedFile < ApplicationRecord
  belongs_to :claim
  belongs_to :uploaded_file
  default_scope { order(created_at: :asc) }
end
