# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class ClaimExport < ApplicationRecord
  belongs_to :claim
  belongs_to :pdf_file, class_name: 'UploadedFile', optional: true # rubocop:disable Rails/InverseOf
end
