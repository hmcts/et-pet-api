# frozen_string_literal: true

class Claim < ApplicationRecord
  has_many :claim_claimants
  has_many :claim_respondents
  has_many :claim_representatives
  has_many :claimants, through: :claim_claimants
  has_many :respondents, through: :claim_respondents
  has_many :representatives, through: :claim_representatives

  accepts_nested_attributes_for :claimants
  accepts_nested_attributes_for :respondents
  accepts_nested_attributes_for :representatives
end
