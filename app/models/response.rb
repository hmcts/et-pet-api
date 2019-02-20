class Response < ApplicationRecord
  belongs_to :respondent
  belongs_to :representative, optional: true
  has_many :response_uploaded_files, dependent: :destroy
  has_many :uploaded_files, through: :response_uploaded_files
  has_many :pre_allocated_file_keys, as: :allocated_to, dependent: :destroy, inverse_of: :allocated_to

  def office
    @office ||= Office.find_by(code: office_code)
  end

  def office_code
    reference[0..1]
  end

  def additional_information_rtf_file?
    ai_file.present?
  end

  def pdf_file
    uploaded_files.detect { |file| file.filename == 'et3_atos_export.pdf' }
  end

  private

  def ai_file
    uploaded_files.detect { |file| file.filename == 'additional_information.rtf' }
  end
end
