# frozen_string_literal: true

# A claim is an employee tribunal claim (form the ET1 form)
class Claim < ApplicationRecord
  has_many :claim_claimants, dependent: :destroy
  has_many :claim_respondents, dependent: :destroy
  has_many :claim_representatives, dependent: :destroy
  has_many :claim_uploaded_files, dependent: :destroy

  belongs_to :primary_claimant, class_name: 'Claimant', inverse_of: false

  has_many :secondary_claimants, dependent: :destroy, class_name: 'Claimant',
                                 through: :claim_claimants, source: :claimant
  belongs_to :primary_respondent, class_name: 'Respondent', inverse_of: false, optional: true
  has_many :secondary_respondents, dependent: :destroy, class_name: 'Respondent',
                                   through: :claim_respondents, source: :respondent
  belongs_to :primary_representative, class_name: 'Representative', inverse_of: false, optional: true
  has_many :secondary_representatives, class_name: 'Representative',
                                       through: :claim_representatives, source: :representative
  has_many :uploaded_files, through: :claim_uploaded_files

  before_save :cache_claimant_count
  # @TODO RST-1080 Refactoring Tasks - 'uploaded_files' really needs renaming as these files are not only
  #   uploaded files but can be generated internally too

  accepts_nested_attributes_for :secondary_claimants
  accepts_nested_attributes_for :primary_claimant
  accepts_nested_attributes_for :uploaded_files

  # A claim can only have one pdf file - this is it
  #
  # @return [UploadedFile, nil] The pdf file if it exists
  def pdf_file
    uploaded_files.detect { |f| f.filename.downcase.ends_with?('.pdf') }
  end

  # A claim can only have one csv file - this is it
  #
  # @return [UploadedFile, nil] The csv file if it exists
  def claimants_csv_file
    uploaded_files.detect { |f| f.filename.downcase.ends_with?('.csv') }
  end

  def multiple_claimants?
    secondary_claimants.length.positive?
  end

  def rtf_file
    uploaded_files.detect { |f| f.filename.downcase.ends_with?('.rtf') }
  end

  private

  def cache_claimant_count
    self.claimant_count = secondary_claimants.length + (primary_claimant.present? ? 1 : 0)
  end
end
