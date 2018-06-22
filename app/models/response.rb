class Response < ApplicationRecord
  belongs_to :respondent
  belongs_to :representative, optional: true
  has_many :response_uploaded_files, dependent: :destroy
  has_many :uploaded_files, through: :response_uploaded_files

  def additional_information_key=(value)
    DirectUploadIntoCollectionService.new(collection: uploaded_files, filename: 'additional_information.rtf').import(value)
  end

  def has_additional_information_rtf_file?
    ai_file.present?
  end

  private

  def ai_file
    uploaded_files.detect { |file| file.filename == 'additional_information.rtf' }
  end
end
