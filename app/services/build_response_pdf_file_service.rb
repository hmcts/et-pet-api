class BuildResponsePdfFileService # rubocop:disable Metrics/ClassLength
  include PdfBuilder::Base
  include PdfBuilder::MultiTemplate
  include PdfBuilder::Rendering
  include PdfBuilder::PreAllocation
  include PdfBuilder::ActiveStorage

  def self.call(source, template_reference: 'et3-v1-en')
    new(source, template_reference: template_reference).call
  end

  def call
    filename = 'et3_atos_export.pdf'
    source.uploaded_files.build filename: filename,
                                file: blob_for_pdf_file(filename)
  end

  private

  def pdf_fields
    result = {}
    apply_header_pdf_fields(result)
    apply_claimant_pdf_fields(result)
    apply_respondent_pdf_fields(result)
    apply_acas_pdf_fields(result)
    apply_employment_details_pdf_fields(result)
    apply_earnings_pdf_fields(result)
    apply_response_pdf_fields(result)
    apply_contract_claim_pdf_fields(result)
    apply_representative_pdf_fields(result)
    apply_disability_pdf_fields(result)
    result
  end

  # Note: A few rubocop disables here as the complexity of the pdf is dictated to us in terms of the file
  # itself.  It is intentional that this complexity is mirrored in a 1-1 mapping so each section is clear
  # in the code as it is in the pdf document.
  #
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def apply_header_pdf_fields(result)
    apply_field result, source.case_number, :header, :case_number
    apply_field result, source.date_of_receipt.try(:strftime, '%d/%m/%Y'), :header, :date_received
    apply_field result, source.additional_information_rtf_file?, :header, :rtf
  end

  def apply_claimant_pdf_fields(result)
    apply_field result, source.claimants_name, :claimant, :claimants_name
  end

  def apply_respondent_pdf_fields(result)
    respondent = source.respondent
    address = respondent.address
    apply_field result, respondent.name, :respondent, :name
    apply_field result, respondent.contact, :respondent, :contact
    apply_field result, address.building, :respondent, :address, :building
    apply_field result, address.street, :respondent, :address, :street
    apply_field result, address.locality, :respondent, :address, :locality
    apply_field result, address.county, :respondent, :address, :county
    apply_field result, address.post_code.tr(' ', ''), :respondent, :address, :post_code
    apply_field result, respondent.dx_number, :respondent, :address_dx_number
    apply_field result, respondent.address_telephone_number, :respondent, :phone_number
    apply_field result, respondent.alt_phone_number, :respondent, :mobile_number
    apply_field result, respondent.contact_preference, :respondent, :contact_preference
    apply_field result, respondent.email_address, :respondent, :email_address
    apply_field result, respondent.fax_number, :respondent, :fax_number
    apply_field result, respondent.organisation_employ_gb, :respondent, :employ_gb
    apply_field result, respondent.organisation_more_than_one_site, :respondent, :multi_site_gb
    apply_field result, respondent.employment_at_site_number, :respondent, :employment_at_site_number
  end

  def apply_acas_pdf_fields(result)
    apply_field result, source.agree_with_early_conciliation_details?, :acas, :agree
    apply_field result, source.disagree_conciliation_reason, :acas, :disagree_explanation
  end

  def apply_employment_details_pdf_fields(result)
    apply_field result, source.agree_with_employment_dates, :employment_details, :agree_with_dates
    apply_field result, source.employment_start.try(:strftime, '%d/%m/%Y'), :employment_details, :employment_start
    apply_field result, source.employment_end.try(:strftime, '%d/%m/%Y'), :employment_details, :employment_end
    apply_field result, source.disagree_employment, :employment_details, :disagree_with_dates_reason
    apply_field result, source.continued_employment?, :employment_details, :continuing
    apply_field result, source.agree_with_claimants_description_of_job_or_title, :employment_details, :agree_with_job_title
    apply_field result, source.disagree_claimants_job_or_title, :employment_details, :correct_job_title
  end

  def apply_earnings_pdf_fields(result)
    apply_field result, source.agree_with_claimants_hours, :earnings, :agree_with_hours
    apply_field result, source.queried_hours, :earnings, :correct_hours
    apply_field result, source.agree_with_earnings_details, :earnings, :agree_with_earnings
    apply_field result, source.queried_pay_before_tax, :earnings, :correct_pay_before_tax
    apply_field result, source.queried_pay_before_tax_period, :earnings, :correct_pay_before_tax_period
    apply_field result, source.queried_take_home_pay, :earnings, :correct_take_home_pay
    apply_field result, source.queried_take_home_pay_period, :earnings, :correct_take_home_pay_period
    apply_field result, source.agree_with_claimant_notice, :earnings, :agree_with_notice_period
    apply_field result, source.disagree_claimant_notice_reason, :earnings, :disagree_notice_period_reason
    apply_field result, source.agree_with_claimant_pension_benefits, :earnings, :agree_with_pension_benefits
    apply_field result, source.disagree_claimant_pension_benefits_reason, :earnings, :disagree_pension_benefits_reason
  end

  def apply_response_pdf_fields(result)
    apply_field result, source.defend_claim?, :response, :defend_claim
    apply_field result, source.defend_claim_facts, :response, :defend_claim_facts
  end

  def apply_contract_claim_pdf_fields(result)
    apply_field result, source.make_employer_contract_claim?, :contract_claim, :make_employer_contract_claim
    apply_field result, source.claim_information, :contract_claim, :information
  end

  def apply_representative_pdf_fields(result)
    representative = source.representative
    return apply_no_representative(result) if representative.nil?

    address = representative.address
    apply_field result, representative.name, :representative, :name
    apply_field result, representative.organisation_name, :representative, :organisation_name
    apply_field result, address.try(:building), :representative, :address, :building
    apply_field result, address.try(:street), :representative, :address, :street
    apply_field result, address.try(:locality), :representative, :address, :locality
    apply_field result, address.try(:county), :representative, :address, :county
    apply_field result, address.try(:post_code).try(:tr, ' ', ''), :representative, :address, :post_code
    apply_field result, representative.dx_number, :representative, :dx_number
    apply_field result, representative.address_telephone_number, :representative, :phone_number
    apply_field result, representative.mobile_number, :representative, :mobile_number
    apply_field result, representative.reference, :representative, :reference
    apply_field result, representative.contact_preference, :representative, :contact_preference
    apply_field result, representative.email_address, :representative, :email_address
    apply_field result, representative.fax_number, :representative, :fax_number
  end

  def apply_no_representative(result)
    apply_field result, '', :representative, :name
    apply_field result, '', :representative, :organisation_name
    apply_field result, '', :representative, :address, :building
    apply_field result, '', :representative, :address, :street
    apply_field result, '', :representative, :address, :locality
    apply_field result, '', :representative, :address, :county
    apply_field result, '', :representative, :address, :post_code
    apply_field result, '', :representative, :dx_number
    apply_field result, '', :representative, :phone_number
    apply_field result, '', :representative, :mobile_number
    apply_field result, '', :representative, :reference
    apply_field result, nil, :representative, :contact_preference
    apply_field result, '', :representative, :email_address
    apply_field result, '', :representative, :fax_number
  end

  def apply_disability_pdf_fields(result)
    respondent = source.respondent
    apply_field result, respondent.disability, :disability, :has_disability
    apply_field result, respondent.disability_information, :disability, :information
  end

  def apply_no_disability_pdf_fields(result)
    apply_field result, nil, :disability, :has_disability
    apply_field result, '', :disability, :information
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
