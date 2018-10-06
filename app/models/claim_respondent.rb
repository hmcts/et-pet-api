# frozen_string_literal: true

# @private
# An internal join model not to be used directly
class ClaimRespondent < ApplicationRecord
  belongs_to :claim
  belongs_to :respondent
  default_scope { order(created_at: :asc) }
end
