require_relative 'base'
require_relative '../../helpers/office_helper'
module EtApi
  module Test
    module FileObjects
      # Represents the ET3 PDF file and provides assistance in validating its contents
=begin
  ["case number", "date_received", "RTF", "1.1", "2.3 postcode", "2.1", "2.2",
  "2.3 number or name", "2.3 street", "2.3 town city", "2.3 county",
  "2.3 dx number", "2.4 phone number", "2.4 mobile number", "2.5", "2.6 email address", "2.6 fax number",
  "2.7", "2.8", "2.9",
  "3.1", "3.1 employment started", "3.1 employment end", "3.1 disagree",
  "3.2", "3.3", "3.3 if no",
  "4.1", "4.1 if no", "4.2", "4.2 pay before tax", "4.2 pay before tax tick box", "4.2 normal take-home pay", "4.2 normal take-home pay tick box", "4.3 tick box", "4.3 if no", "4.4 tick box", "4.4 if no",
  "5.1 tick box", "5.1 if yes",
  "6.2 tick box", "6.3", "7.3 postcode",
  "7.1", "7.2", "7.3 number or name", "7.3 street", "7.3 town city", "7.3 county", "7.4", "7.5 phone number", "7.6", "7.7", "7.8 tick box", "7.9", "7.10",
  "8.1 tick box", "8.1 if yes", "8.1 please re-read", "additional space for notes", "new 3.1", "new 3.1 If no, please explain why"]
=end
=begin
 mappings:

  3.2 => 4.2 (yes, no)
  3.3 => 4.3 (yes, no)

email_receipt does not go to pdf
representative_type does not go to pdf

=end
      class Et3PdfFile < Base # rubocop:disable Metrics/ClassLength
        include RSpec::Matchers

        def initalize(tempfile)
          self.tempfile = tempfile
        end

        def has_correct_contents_for?(response:, respondent:, representative:, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_header_for?(response, errors: errors, indent: indent) &&
            has_claimant_for?(response, errors: errors, indent: indent) &&
            has_respondent_for?(respondent, errors: errors, indent: indent) &&
            has_acas_for?(response, errors: errors, indent: indent) &&
            has_employment_details_for?(response, errors: errors, indent: indent) &&
            has_earnings_for?(response, errors: errors, indent: indent) &&
            has_response_for?(response, errors: errors, indent: indent) &&
            has_contract_claim_for?(response, errors: errors, indent: indent) &&
            has_representative_for?(representative, errors: errors, indent: indent) &&
            has_disability_for?(representative, errors: errors, indent: indent)
        end

        def has_correct_contents_from_db_for?(response:, errors: [], indent: 1)
          respondent = response.respondent.as_json(include: :address).symbolize_keys
          representative = response.representative.try(:as_json, include: :address).try(:symbolize_keys)
          respondent[:address_attributes] = respondent.delete(:address).symbolize_keys
          representative[:address_attributes] = representative.delete(:address).symbolize_keys unless representative.nil?
          response = response.as_json.symbolize_keys
          has_correct_contents_for?(response: response, respondent: respondent, representative: representative, errors: errors, indent: indent)
        end

        def has_header_for?(response, errors: [], indent: 1)
          validate_fields section: :header, errors: errors, indent: indent do
            expect(field_values).to include 'case number' => response[:case_number]
          end
        end

        def has_claimant_for?(response, errors: [], indent: 1)
          validate_fields section: :claimant, errors: errors, indent: indent do
            expect(field_values).to include '1.1' => response[:claimants_name]
          end
        end

        def has_respondent_for?(respondent, errors: [], indent: 1)
          address = respondent[:address_attributes]
          validate_fields section: :respondent, errors: errors, indent: indent do
            expect(field_values).to include '2.1' => respondent[:name]
            expect(field_values).to include '2.2' => respondent[:contact]
            expect(field_values).to include '2.3 number or name' => address[:building]
            expect(field_values).to include '2.3 street' => address[:street]
            expect(field_values).to include '2.3 town city' => address[:locality]
            expect(field_values).to include '2.3 county' => address[:county]
            expect(field_values).to include '2.3 postcode' => address[:post_code].tr(' ', '')
            expect(field_values).to include '2.3 dx number' => respondent[:dx_number]
            expect(field_values).to include '2.4 phone number' => respondent[:address_telephone_number]
            expect(field_values).to include '2.4 mobile number' => respondent[:alt_phone_number]
            expect(field_values).to include '2.5' => respondent[:contact_preference]
            expect(field_values).to include '2.6 email address' => respondent[:email_address]
            expect(field_values).to include '2.6 fax number' => respondent[:fax_number]
            expect(field_values).to include '2.7' => respondent[:organisation_employ_gb].to_s
            expect(field_values).to include '2.8' => respondent[:organisation_more_than_one_site] ? 'yes' : 'no'
            expect(field_values).to include '2.9' => respondent[:employment_at_site_number].to_s
          end
        end

        def has_acas_for?(response, errors: [], indent: 1)
          validate_fields section: :acas, errors: errors, indent: indent do
            expect(field_values).to include 'new 3.1' => response[:agree_with_early_conciliation_details] ? 'yes' : 'no'
            expect(field_values).to include 'new 3.1 If no, please explain why' => response[:disagree_conciliation_reason]
          end
        end

        def has_employment_details_for?(response, errors: [], indent: 1)
          validate_fields section: :employment, errors: errors, indent: indent do
            expect(field_values).to include '3.1' => response[:agree_with_employment_dates] ? 'yes' : 'no'
            expect(field_values).to include '3.1 employment started' => date_for(response[:employment_start])
            expect(field_values).to include '3.1 employment end' => date_for(response[:employment_end])
            expect(field_values).to include '3.1 disagree' => response[:disagree_employment]
            expect(field_values).to include '3.2' => response[:continued_employment] ? 'yes' : 'no'
            expect(field_values).to include '3.3' => response[:agree_with_claimants_description_of_job_or_title] ? 'yes' : 'no'
            expect(field_values).to include '3.3 if no' => response[:disagree_claimants_job_or_title] ? 'yes' : 'no'
          end
        end

        def has_earnings_for?(response, errors: [], indent: 1)
          validate_fields section: :earnings, errors: errors, indent: indent do
            expect(field_values).to include '4.1' => response[:agree_with_claimants_hours] ? 'yes' : 'no'
            expect(field_values).to include '4.1 if no' => decimal_for(response[:queried_hours])
            expect(field_values).to include '4.2' => response[:agree_with_earnings_details] ? 'yes' : 'no'
            expect(field_values).to include '4.2 pay before tax' => decimal_for(response[:queried_pay_before_tax])
            expect(field_values).to include '4.2 pay before tax tick box' => response[:queried_pay_before_tax_period].downcase
            expect(field_values).to include '4.2 normal take-home pay' => decimal_for(response[:queried_take_home_pay])
            expect(field_values).to include '4.2 normal take-home pay tick box' => response[:queried_take_home_pay_period].downcase
            expect(field_values).to include '4.3 tick box' => response[:agree_with_claimant_notice] ? 'yes' : 'no'
            expect(field_values).to include '4.3 if no' => response[:disagree_claimant_notice_reason]
            expect(field_values).to include '4.4 tick box' => response[:agree_with_claimant_pension_benefits] ? 'yes' : 'no'
            expect(field_values).to include '4.4 if no' => response[:disagree_claimant_pension_benefits_reason]
          end
        end

        def has_response_for?(response, errors: [], indent: 1)
          validate_fields section: :response, errors: errors, indent: indent do
            expect(field_values).to include '5.1 tick box' => response[:defend_claim] ? 'yes' : 'no'
            expect(field_values).to include '5.1 if yes' => response[:defend_claim_facts]
          end
        end

        def has_contract_claim_for?(response, errors: [], indent: 1)
          validate_fields section: :contract_claim, errors: errors, indent: indent do
            expect(field_values).to include '6.2 tick box' => response[:make_employer_contract_claim] ? 'yes' : 'Off'
            expect(field_values).to include '6.3' => response[:claim_information]

          end
        end

        def has_representative_for?(representative, errors: [], indent: 1)
          return has_no_representative?(errors: errors, indent: indent) if representative.nil?
          address = representative[:address_attributes]
          validate_fields section: :representative, errors: errors, indent: indent do
            expect(field_values).to include '7.1' => representative[:name]
            expect(field_values).to include '7.2' => representative[:organisation_name]
            expect(field_values).to include '7.3 number or name' => address[:building]
            expect(field_values).to include '7.3 street' => address[:street]
            expect(field_values).to include '7.3 town city' => address[:locality]
            expect(field_values).to include '7.3 county' => address[:county]
            expect(field_values).to include '7.3 postcode' => address[:post_code].tr(' ', '')
            expect(field_values).to include '7.4' => representative[:dx_number]
            expect(field_values).to include '7.5 phone number' => representative[:address_telephone_number]
            expect(field_values).to include '7.6' => representative[:mobile_number]
            expect(field_values).to include '7.7' => representative[:reference]
            expect(field_values).to include '7.8 tick box' => representative[:contact_preference]
            expect(field_values).to include '7.9' => representative[:email_address]
            expect(field_values).to include '7.10' => representative[:fax_number]
          end
        end

        def has_no_representative?(errors: [], indent: 1)
          validate_fields section: :representative, errors: errors, indent: indent do
            expect(field_values).to include '7.1' => ''
            expect(field_values).to include '7.2' => ''
            expect(field_values).to include '7.3 number or name' => ''
            expect(field_values).to include '7.3 street' => ''
            expect(field_values).to include '7.3 town city' => ''
            expect(field_values).to include '7.3 county' => ''
            expect(field_values).to include '7.3 postcode' => ''
            expect(field_values).to include '7.4' => ''
            expect(field_values).to include '7.5 phone number' => ''
            expect(field_values).to include '7.6' => ''
            expect(field_values).to include '7.7' => ''
            expect(field_values).to include '7.8 tick box' => ''
            expect(field_values).to include '7.9' => ''
            expect(field_values).to include '7.10' => ''
          end
        end

        def has_disability_for?(representative, errors: [], indent: 1)
          return has_no_disability?(errors: errors, indent: indent) if representative.nil?
          validate_fields section: :disability, errors: errors, indent: indent do
            expect(field_values).to include '8.1 tick box' => representative[:disability] ? 'yes' : 'no'
            expect(field_values).to include '8.1 if yes' => representative[:disability_information]
          end
        end

        def has_no_disability?(errors: [], indent: 1)
          validate_fields section: :disability, errors: errors, indent: indent do
            expect(field_values).to include '8.1 tick box' => 'Off'
            expect(field_values).to include '8.1 if yes' => ''
          end
        end

        private

        attr_accessor :tempfile

        def field_values
          @field_values ||= form.fields.inject({}) do |acc, field|
            acc[field.name] = field.value
            acc
          end
        end

        def form
          @form ||= PdfForms.new('pdftk').read(tempfile.path)
        end

        def validate_fields(section:, errors:, indent:)
          aggregate_failures "Match pdf contents to input data" do
            yield
          end
          true
        rescue RSpec::Expectations::ExpectationNotMetError => err
          errors << "Invalid '#{section.to_s.humanize}' section in pdf"
          errors.concat(err.message.lines.map { |l| "#{'  ' * indent}#{l.gsub(/\n\z/, '')}" })
          false
        end

        def date_for(date)
          return date.strftime('%d/%m/%Y') if date.is_a?(Date) || date.is_a?(Time) || date.is_a?(DateTime)
          Time.zone.parse(date).strftime('%d/%m/%Y')
        end

        def decimal_for(number)
          number.to_s
        end


      end
    end
  end
end
