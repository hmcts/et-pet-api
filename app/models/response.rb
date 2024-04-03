class Response < ApplicationRecord
  include CcdExportable
  belongs_to :respondent
  belongs_to :representative, optional: true
  has_many :response_uploaded_files, dependent: :destroy
  has_many :uploaded_files, through: :response_uploaded_files
  has_many :pre_allocated_file_keys, as: :allocated_to, dependent: :destroy, inverse_of: :allocated_to
  has_many :events, as: :attached_to, dependent: :destroy
  belongs_to :office
  has_many :commands, as: :root_object, dependent: :destroy
  has_many :exports, as: :resource, dependent: :destroy

  scope :submitted_before, lambda { |date_time|
    where(date_of_receipt: ..date_time)
  }

  def office_code
    reference[0..1]
  end

  def additional_information_file?
    additional_information_file.present?
  end

  def pdf_file
    uploaded_files.system_file_scope.detect { |file| file.filename == 'et3_atos_export.pdf' }
  end

  def additional_information_file
    uploaded_files.detect { |file| file.filename == 'additional_information.rtf' }
  end
end
