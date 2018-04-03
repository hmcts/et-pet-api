# frozen_string_literal: true

class ClaimRespondent < ApplicationRecord
  belongs_to :claim
  belongs_to :respondent
end
