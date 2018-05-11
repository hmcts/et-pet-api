# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class ClaimExport < ApplicationRecord
  belongs_to :resource, polymorphic: true
end
