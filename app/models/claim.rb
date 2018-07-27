# frozen_string_literal: true

# A claim is an employee tribunal claim (form the ET1 form)
class Claim < ApplicationRecord
  has_many :claim_claimants, dependent: :destroy
  has_many :claim_respondents, dependent: :destroy
  has_many :claim_representatives, dependent: :destroy
  has_many :claim_uploaded_files, dependent: :destroy

  has_many :claimants, through: :claim_claimants
  has_many :respondents, through: :claim_respondents
  has_many :representatives, through: :claim_representatives
  has_many :uploaded_files, through: :claim_uploaded_files

  before_save :cache_claimant_count
  # @TODO RST-1080 Refactoring Tasks - 'uploaded_files' really needs renaming as these files are not only
  #   uploaded files but can be generated internally too

  accepts_nested_attributes_for :claimants
  accepts_nested_attributes_for :respondents
  accepts_nested_attributes_for :representatives
  accepts_nested_attributes_for :uploaded_files

  # A claim can only have one pdf file - this is it
  #
  # @return [UploadedFile, nil] The pdf file if it exists
  def pdf_file
    uploaded_files.detect { |f| f.filename.ends_with?('.pdf') }
  end

  # The first claimant is always the primary claimant - this method returns that
  #
  # @return [Claimant, nil] The primary claimant if it exists
  def primary_claimant
    claimants.first
  end

  private

  def cache_claimant_count
    self.claimant_count = claimants.length
  end
end
