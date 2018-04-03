# frozen_string_literal: true

class Claim < ApplicationRecord
  has_many :claim_claimants
  has_many :claim_respondents
  has_many :claim_representatives
  has_many :claim_uploaded_files
  has_many :claimants, through: :claim_claimants
  has_many :respondents, through: :claim_respondents
  has_many :representatives, through: :claim_representatives
  has_many :uploaded_files, through: :claim_uploaded_files

  accepts_nested_attributes_for :claimants
  accepts_nested_attributes_for :respondents
  accepts_nested_attributes_for :representatives
  accepts_nested_attributes_for :uploaded_files

  after_commit :queue_send_pdf_to_landing_folder, only: :create

  private

  def pdf_file
    uploaded_files.detect {|f| f.filename.ends_with?('.pdf')}
  end

  def primary_claimant
    claimants.first
  end

  def queue_send_pdf_to_landing_folder
    ClaimShipPdfFileJob.perform_later(file: pdf_file, destination_filename: "#{reference}PP_ET1_#{primary_claimant.first_name}_#{primary_claimant.last_name}.pdf")
  end
end
