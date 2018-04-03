# frozen_string_literal: true

class Claim < ApplicationRecord
  has_many :claim_claimants
  has_many :claim_respondents
  has_many :claimants, through: :claim_claimants
  has_many :respondents, through: :claim_respondents

  accepts_nested_attributes_for :claimants
  accepts_nested_attributes_for :respondents
end
