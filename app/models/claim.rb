# frozen_string_literal: true

class Claim < ApplicationRecord
  has_many :claim_claimants, dependent: :destroy
  has_many :claim_respondents, dependent: :destroy
  has_many :claim_representatives, dependent: :destroy
  has_many :claim_uploaded_files, dependent: :destroy
  has_many :claimants, through: :claim_claimants
  has_many :respondents, through: :claim_respondents
  has_many :representatives, through: :claim_representatives
  has_many :uploaded_files, through: :claim_uploaded_files

  accepts_nested_attributes_for :claimants
  accepts_nested_attributes_for :respondents
  accepts_nested_attributes_for :representatives
  accepts_nested_attributes_for :uploaded_files

  def pdf_file
    uploaded_files.detect { |f| f.filename.ends_with?('.pdf') }
  end

  def primary_claimant
    claimants.first
  end
end
