module ResponseFileBuilder
  class BuildResponsePdfFile
    include PdfBuilder

    def self.call(response)
      new(response).call
    end

    def initialize(response, template_path: Rails.root.join('vendor', 'assets', 'pdf_forms', 'et3.pdf'))
      self.response = response
      self.template_path = template_path
    end

    def call
      filename = 'et3_atos_export.pdf'
      response.uploaded_files.build filename: filename,
        file: blob_for_pdf_file(filename)
    end

    private

    attr_accessor :response, :template_path

    def blob_for_pdf_file(filename)
      ActiveStorage::Blob.new.tap do |blob|
        blob.filename = filename
        blob.content_type = 'application/pdf'
        blob.metadata = nil
        blob.key = pre_allocated_key
        blob.upload render_to_file
      end
    end

    def pre_allocated_key
      response.pre_allocated_file_keys.where(filename: 'et3_atos_export.pdf').first.try(:key)
    end

    def render_to_file
      tempfile = Tempfile.new
      fill_in_pdf_form(template_path: template_path, to: tempfile.path, data: pdf_fields)
      tempfile
    end

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

    def tri_state_value_for(value, yes: 'yes', no: 'no', off: 'Off')
      return off if value.nil?
      value ? yes : no
    end

    def apply_header_pdf_fields(result)
      result['case number'] = response.case_number
      result['date_received'] = response.date_of_receipt.try(:strftime, '%d/%m/%Y')
      result['RTF'] = response.additional_information_rtf_file? ? 'Additional RTF' : ''
    end

    def apply_claimant_pdf_fields(result)
      result['1.1'] = response.claimants_name
    end

    def apply_respondent_pdf_fields(result)
      respondent = response.respondent
      address = respondent.address
      result['2.1'] = respondent.name
      result['2.2'] = respondent.contact
      result['2.3 number or name'] = address.building
      result['2.3 street'] = address.street
      result['2.3 town city'] = address.locality
      result['2.3 county'] = address.county
      result['2.3 postcode'] = address.post_code.tr(' ', '')
      result['2.3 dx number'] = respondent.dx_number
      result['2.4 phone number'] = respondent.address_telephone_number
      result['2.4 mobile number'] = respondent.alt_phone_number
      result['2.5'] = respondent.contact_preference || 'Off'
      result['2.6 email address'] = respondent.email_address
      result['2.6 fax number'] = respondent.fax_number
      result['2.7'] = respondent.organisation_employ_gb
      result['2.8'] = respondent.organisation_more_than_one_site ? 'yes' : 'no'
      result['2.9'] = respondent.employment_at_site_number
    end

    def apply_acas_pdf_fields(result)
      result['new 3.1'] = response.agree_with_early_conciliation_details ? 'Yes' : 'No'
      result['new 3.1 If no, please explain why'] = response.disagree_conciliation_reason
    end

    def apply_employment_details_pdf_fields(result)
      result['3.1'] = response.agree_with_employment_dates ? 'yes' : 'no'
      result['3.1 employment started'] = response.employment_start.try(:strftime, '%d/%m/%Y')
      result['3.1 employment end'] = response.employment_end.try(:strftime, '%d/%m/%Y')
      result['3.1 disagree'] = response.disagree_employment
      result['3.2'] = response.continued_employment ? 'yes' : 'no'
      result['3.3'] = tri_state_value_for(response.agree_with_claimants_description_of_job_or_title)
      result['3.3 if no'] = response.disagree_claimants_job_or_title ? 'yes' : 'no'
    end

    def apply_earnings_pdf_fields(result)
      result['4.1'] = tri_state_value_for(response.agree_with_claimants_hours)
      result['4.1 if no'] = response.queried_hours
      result['4.2'] = tri_state_value_for(response.agree_with_earnings_details)
      result['4.2 pay before tax'] = response.queried_pay_before_tax
      result['4.2 pay before tax tick box'] = response.queried_pay_before_tax_period.try(:downcase) || 'Off'
      result['4.2 normal take-home pay'] = response.queried_take_home_pay
      result['4.2 normal take-home pay tick box'] = response.queried_take_home_pay_period.try(:downcase) || 'Off'
      result['4.3 tick box'] = tri_state_value_for(response.agree_with_claimant_notice)
      result['4.3 if no'] = response.disagree_claimant_notice_reason
      result['4.4 tick box'] = tri_state_value_for(response.agree_with_claimant_pension_benefits)
      result['4.4 if no'] = response.disagree_claimant_pension_benefits_reason
    end

    def apply_response_pdf_fields(result)
      result['5.1 tick box'] = response.defend_claim ? 'yes' : 'no'
      result['5.1 if yes'] = response.defend_claim_facts
    end

    def apply_contract_claim_pdf_fields(result)
      result['6.2 tick box'] = response.make_employer_contract_claim ? 'yes' : 'Off'
      result['6.3'] = response.claim_information
    end

    def apply_representative_pdf_fields(result)
      representative = response.representative
      return apply_no_representative(result) if representative.nil?
      address = representative.address
      result['7.1'] = representative.name
      result['7.2'] = representative.organisation_name
      result['7.3 number or name'] = address.try(:building)
      result['7.3 street'] = address.try(:street)
      result['7.3 town city'] = address.try(:locality)
      result['7.3 county'] = address.try(:county)
      result['7.3 postcode'] = address.try(:post_code).try(:tr, ' ', '')
      result['7.4'] = representative.dx_number
      result['7.5 phone number'] = representative.address_telephone_number
      result['7.6'] = representative.mobile_number
      result['7.7'] = representative.reference
      result['7.8 tick box'] = representative.contact_preference || 'Off'
      result['7.9'] = representative.email_address
      result['7.10'] = representative.fax_number
    end

    def apply_no_representative(result)
      result['7.1'] = ''
      result['7.2'] = ''
      result['7.3 number or name'] = ''
      result['7.3 street'] = ''
      result['7.3 town city'] = ''
      result['7.3 county'] = ''
      result['7.3 postcode'] = ''
      result['7.4'] = ''
      result['7.5 phone number'] = ''
      result['7.6'] = ''
      result['7.7'] = ''
      result['7.8 tick box'] = 'Off'
      result['7.9'] = ''
      result['7.10'] = ''
    end

    def apply_disability_pdf_fields(result)
      respondent = response.respondent
      result['8.1 tick box'] = tri_state_value_for(respondent.disability)
      result['8.1 if yes'] = respondent.disability_information
    end

    def apply_no_disability_pdf_fields(result)
      result['8.1 tick box'] = 'Off'
      result['8.1 if yes'] = ''
    end
  end
end
