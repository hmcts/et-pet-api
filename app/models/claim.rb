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
  has_many :pre_allocated_file_keys, as: :allocated_to, dependent: :destroy, inverse_of: :allocated_to
  belongs_to :office, foreign_key: :office_code, primary_key: :code # rubocop:disable Rails/InverseOf
  has_many :events, as: :attached_to, dependent: :destroy
  has_many :commands, as: :root_object, dependent: :destroy

  before_save :cache_claimant_count

  accepts_nested_attributes_for :secondary_claimants
  accepts_nested_attributes_for :primary_claimant
  accepts_nested_attributes_for :uploaded_files

  # A claim can now have multiple pdf's but this method returns the application pdf
  #
  # @return [UploadedFile, nil] The pdf file if it exists
  def pdf_file
    uploaded_files.system_file_scope.detect { |f| f.filename.end_with?('.pdf') && !f.filename.start_with?('acas') && !f.filename.start_with?('et1_attachment_') }
  end

  # A claim can only have one csv file - this is it
  #
  # @return [UploadedFile, nil] The csv file if it exists
  def claimants_csv_file
    uploaded_files.user_file_scope.detect { |f| f.filename.downcase.ends_with?('.csv') }
  end

  def multiple_claimants?
    secondary_claimants.length.positive?
  end

  def claim_details_input_file
    uploaded_files.detect { |f| f.filename.downcase.ends_with?('.rtf') }
  end

  private

  def cache_claimant_count
    self.claimant_count = secondary_claimants.length + (primary_claimant.present? ? 1 : 0)
  end
end
