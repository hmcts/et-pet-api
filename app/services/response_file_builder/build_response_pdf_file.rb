module ResponseFileBuilder
  class BuildResponsePdfFile # rubocop:disable Metrics/ClassLength
    include PdfBuilder

    def self.call(response, template_reference: 'et3-v1-en')
      new(response, template_reference: template_reference).call
    end

    def initialize(response, template_reference:, template_dir: Rails.root.join('vendor', 'assets', 'pdf_forms'))
      self.response = response
      self.template_dir = template_dir
      self.template_reference = template_reference
      self.yaml_file = File.join(template_dir, "#{template_reference}.yml")
    end

    def call
      filename = 'et3_atos_export.pdf'
      response.uploaded_files.build filename: filename,
                                    file: blob_for_pdf_file(filename)
    end

    private

    attr_accessor :response, :template_dir, :template_reference, :yaml_file

    def yaml_data
      @yaml_data ||= YAML.load_file(yaml_file).with_indifferent_access
    end

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
      template_path = File.join(template_dir, "#{template_reference}.pdf")
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

    def apply_selected_value_for(result, field_def, field_value)
      if field_def[:field_name].is_a?(Array)
        results = selected_value_for(field_def, field_value)
        field_def[:field_name].each_with_index do |field_name, idx|
          result[field_name] = results[idx]
        end
      else
        result[field_def[:field_name]] = selected_value_for(field_def, field_value)
      end
    end

    def selected_value_for(field_def, field_value)
      if field_value.nil?
        field_def[:unselected_value]
      else
        raise "Value of #{field_value} is not valid for the field definition #{field_def[:field_name]}" unless field_def[:select_values].key?(field_value)
        field_def[:select_values][field_value]
      end
    end

    def apply_header_pdf_fields(result)
      apply_field result, response.case_number, :header, :case_number
      apply_field result, response.date_of_receipt.try(:strftime, '%d/%m/%Y'), :header, :date_received
      apply_field result, response.additional_information_rtf_file?, :header, :rtf
    end

    def apply_claimant_pdf_fields(result)
      apply_field result, response.claimants_name, :claimant, :claimants_name
    end

    def apply_respondent_pdf_fields(result)
      respondent = response.respondent
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
      apply_field result, response.agree_with_early_conciliation_details?, :acas, :agree
      apply_field result, response.disagree_conciliation_reason, :acas, :disagree_explanation
    end

    def apply_employment_details_pdf_fields(result)
      apply_field result, response.agree_with_employment_dates, :employment_details, :agree_with_dates
      apply_field result, response.employment_start.try(:strftime, '%d/%m/%Y'), :employment_details, :employment_start
      apply_field result, response.employment_end.try(:strftime, '%d/%m/%Y'), :employment_details, :employment_end
      apply_field result, response.disagree_employment, :employment_details, :disagree_with_dates_reason
      apply_field result, response.continued_employment?, :employment_details, :continuing
      apply_field result, response.agree_with_claimants_description_of_job_or_title, :employment_details, :agree_with_job_title
      apply_field result, response.disagree_claimants_job_or_title, :employment_details, :correct_job_title
    end

    def apply_earnings_pdf_fields(result)
      apply_field result, response.agree_with_claimants_hours, :earnings, :agree_with_hours
      apply_field result, response.queried_hours, :earnings, :correct_hours
      apply_field result, response.agree_with_earnings_details, :earnings, :agree_with_earnings
      apply_field result, response.queried_pay_before_tax, :earnings, :correct_pay_before_tax
      apply_field result, response.queried_pay_before_tax_period, :earnings, :correct_pay_before_tax_period
      apply_field result, response.queried_take_home_pay, :earnings, :correct_take_home_pay
      apply_field result, response.queried_take_home_pay_period, :earnings, :correct_take_home_pay_period
      apply_field result, response.agree_with_claimant_notice, :earnings, :agree_with_notice_period
      apply_field result, response.disagree_claimant_notice_reason, :earnings, :disagree_notice_period_reason
      apply_field result, response.agree_with_claimant_pension_benefits, :earnings, :agree_with_pension_benefits
      apply_field result, response.disagree_claimant_pension_benefits_reason, :earnings, :disagree_pension_benefits_reason
    end

    def apply_response_pdf_fields(result)
      apply_field result, response.defend_claim?, :response, :defend_claim
      apply_field result, response.defend_claim_facts, :response, :defend_claim_facts
    end

    def apply_contract_claim_pdf_fields(result)
      apply_field result, response.make_employer_contract_claim?, :contract_claim, :make_employer_contract_claim
      apply_field result, response.claim_information, :contract_claim, :information
    end

    def apply_representative_pdf_fields(result)
      representative = response.representative
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
      respondent = response.respondent
      apply_field result, respondent.disability, :disability, :has_disability
      apply_field result, respondent.disability_information, :disability, :information
    end

    def apply_no_disability_pdf_fields(result)
      apply_field result, nil, :disability, :has_disability
      apply_field result, '', :disability, :information
    end
  end
end
