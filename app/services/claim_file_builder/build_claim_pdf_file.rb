module ClaimFileBuilder
  class BuildClaimPdfFile # rubocop:disable Metrics/ClassLength
    include PdfBuilder

    def self.call(claim, template_reference: 'et1-v1-en')
      new(claim, template_reference: template_reference).call
    end

    def initialize(claim, template_reference:, template_dir: Rails.root.join('vendor', 'assets', 'pdf_forms'))
      self.claim = claim
      self.template_dir = template_dir
      self.template_reference = template_reference
      self.yaml_file = File.join(template_dir, "#{template_reference}.yml")
    end

    def call
      filename = 'et1_atos_export.pdf'
      claim.uploaded_files.build filename: filename,
                                    file: blob_for_pdf_file(filename)
    end

    private

    attr_accessor :claim, :template_dir, :template_reference, :yaml_file

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
      claim.pre_allocated_file_keys.where(filename: 'et1_atos_export.pdf').first.try(:key)
    end

    def render_to_file
      tempfile = Tempfile.new
      template_path = File.join(template_dir, "#{template_reference}.pdf")
      fill_in_pdf_form(template_path: template_path, to: tempfile.path, data: pdf_fields)
      tempfile
    end

    def pdf_fields
      result = {}
      apply_your_details_fields(result)
      apply_respondents_details_fields(result)
      apply_multiple_cases_section(result)
      apply_employment_details_section(result)
      apply_earnings_and_benefits_section(result)
      apply_what_happened_since_section(result)
      result
    end

    def apply_field(result, field_value, *path)
      field_def = yaml_data.dig(*path)
      raise "Field #{path} does not exist in the file #{yaml_file}" unless field_def
      return if field_def[:field_name] == false
      if field_def.key?(:select_values)
        apply_selected_value_for(result, field_def, field_value)
      else
        result[field_def[:field_name]] = field_value
      end
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

    def apply_your_details_fields(result)
      primary_claimant = claim.primary_claimant
      pca = primary_claimant.address
      apply_field result, primary_claimant.title, :your_details, :title
      apply_field result, primary_claimant.first_name, :your_details, :first_name
      apply_field result, primary_claimant.last_name, :your_details, :last_name
      apply_field result, primary_claimant.gender, :your_details, :gender
      apply_field result, pca.building, :your_details, :building
      apply_field result, pca.street, :your_details, :street
      apply_field result, pca.locality, :your_details, :locality
      apply_field result, pca.county, :your_details, :county
      apply_field result, post_code_for(pca.post_code), :your_details, :post_code
      apply_field result, primary_claimant.mobile_number, :your_details, :alternative_telephone_number
      apply_field result, primary_claimant.contact_preference, :your_details, :correspondence
      apply_field result, primary_claimant.date_of_birth.day, :your_details, :dob_day
      apply_field result, primary_claimant.date_of_birth.month, :your_details, :dob_month
      apply_field result, primary_claimant.date_of_birth.year, :your_details, :dob_year
      apply_field result, primary_claimant.email_address, :your_details, :email_address
      apply_field result, primary_claimant.address_telephone_number, :your_details, :telephone_number
    end

    def apply_respondents_details_fields(result)
      resp1 = claim.primary_respondent
      apply_field result, resp1.name, :respondents_details, :name
      apply_field result, resp1.acas_number, :respondents_details, :acas, :acas_number
      apply_field result, resp1.acas_number.present?, :respondents_details, :acas, :have_acas
      apply_field result, resp1.address.building, :respondents_details, :address, :building
      apply_field result, resp1.address.street, :respondents_details, :address, :street
      apply_field result, resp1.address.locality, :respondents_details, :address, :locality
      apply_field result, resp1.address.county, :respondents_details, :address, :county
      apply_field result, post_code_for(resp1.address.post_code), :respondents_details, :address, :post_code
      apply_field result, resp1.address_telephone_number, :respondents_details, :address, :telephone_number
      apply_field result, resp1.work_address.building, :respondents_details, :different_address, :building
      apply_field result, resp1.work_address.street, :respondents_details, :different_address, :street
      apply_field result, resp1.work_address.locality, :respondents_details, :different_address, :locality
      apply_field result, resp1.work_address.county, :respondents_details, :different_address, :county
      apply_field result, post_code_for(resp1.work_address.post_code), :respondents_details, :different_address, :post_code
      apply_field result, resp1.work_address_telephone_number, :respondents_details, :different_address, :telephone_number
    end

    def apply_multiple_cases_section(result)
      apply_field result, claim.other_known_claimant_names&.present?, :multiple_cases, :have_similar_claims
      apply_field result, claim.other_known_claimant_names, :multiple_cases, :other_claimants
    end

    def apply_employment_details_section(result)
      ed = claim.employment_details.symbolize_keys
      apply_field result, ed[:end_date].nil? || Time.zone.parse(ed[:end_date]).future?, :employment_details, :employment_continuing
      apply_field result, ed[:job_title], :employment_details, :job_title
      apply_field result, date_for(ed[:start_date], optional: true), :employment_details, :start_date
      apply_field result, date_for(ed[:end_date], optional: true), :employment_details, :ended_date
      apply_field result, date_for(ed[:notice_period_end_date], optional: true), :employment_details, :ending_date
    end

    def apply_earnings_and_benefits_section(result)
      ed = claim.employment_details.symbolize_keys
      apply_field result, ed[:average_hours_worked_per_week], :earnings_and_benefits, :average_weekly_hours
      apply_field result, ed[:benefit_details], :earnings_and_benefits, :benefits
      apply_field result, ed[:enrolled_in_pension_scheme], :earnings_and_benefits, :employers_pension_scheme
      apply_field result, ed[:notice_pay_period_type] == 'monthly' ? ed[:notice_pay_period_count] : '', :earnings_and_benefits, :notice_period, :months
      apply_field result, ed[:notice_pay_period_type] == 'weekly' ? ed[:notice_pay_period_count] : '', :earnings_and_benefits, :notice_period, :weeks
      apply_field result, ed[:gross_pay]&.to_s, :earnings_and_benefits, :pay_before_tax, :amount
      apply_field result, ed[:gross_pay_period_type], :earnings_and_benefits, :pay_before_tax, :period
      apply_field result, ed[:net_pay]&.to_s, :earnings_and_benefits, :pay_after_tax, :amount
      apply_field result, ed[:net_pay_period_type], :earnings_and_benefits, :pay_after_tax, :period
    end

    def apply_what_happened_since_section(result)
      ed = claim.employment_details.symbolize_keys
      apply_field result, ed[:found_new_job], :what_happened_since, :have_another_job
      apply_field result, date_for(ed[:new_job_start_date], optional: true), :what_happened_since, :start_date
      apply_field result, ed[:new_job_gross_pay], :what_happened_since, :salary
    end

    def post_code_for(val, optional: false)
      return nil if val.nil? && optional
      match = val.match(/\A\s*(\S+)\s*(\d\w\w)\s*\z/)
      return val.slice(0,7) unless match
      spaces = 4 - match[1].length
      val = "#{match[1]}#{' ' * spaces}#{match[2]}"
      val.slice(0,7)
    end

    def date_for(date, optional: false)
      return nil if date.nil? && optional
      date = Date.parse(date) if date.is_a?(String)
      date.strftime "%d/%m/%Y"
    end
  end
end
