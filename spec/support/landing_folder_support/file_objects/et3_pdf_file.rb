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
            has_disability_for?(representative, errors: errors, indent: indent) &&
            has_footer_section?(errors: errors, indent: indent)
        end

        def has_header_for?(response, errors: [], indent: 1)
          validate_fields section: :header, errors: errors, indent: indent do
            expect(fields['case number'].value).to eql response.case_number
          end
        end

        def has_claimant_for?(response, errors: [], indent: 1)
          validate_fields section: :claimant, errors: errors, indent: indent do
            expect(fields['1.1'].value).to eql response.claimants_name
          end
        end

        def has_respondent_for?(respondent, errors: [], indent: 1)
          address = respondent[:address_attributes]
          validate_fields section: :respondent, errors: errors, indent: indent do
            expect(fields['2.1'].value).to eql respondent.name
            expect(fields['2.2'].value).to eql respondent.contact
            expect(fields['2.3 number or name'].value).to eql address.building
            expect(fields['2.3 street'].value).to eql address.street
            expect(fields['2.3 town city'].value).to eql address.locality
            expect(fields['2.3 town county'].value).to eql address.county
            expect(fields['2.3 postcode'].value).to eql address.post_code
            expect(fields['2.3 dx number'].value).to eql respondent.dx_number
            expect(fields['2.4 phone number'].value).to eql respondent.address_telephone_number
            expect(fields['2.4 mobile number'].value).to eql respondent.alt_phone_number
            expect(fields['2.5'].value).to eql respondent.contact_preference
            expect(fields['2.6 email address'].value).to eql respondent.email_address
            expect(fields['2.6 fax number'].value).to eql respondent.fax_number
            expect(fields['2.7'].value).to eql respondent.organisation_employ_gb
            expect(fields['2.8'].value).to eql respondent.organisation_more_than_one_site ? 'yes' : 'no'
            expect(fields['2.9'].value).to eql respondent.employment_at_site_number
          end
        end

        def has_acas_for?(response, errors: [], indent: 1)
          validate_fields section: :acas, errors: errors, indent: indent do
            expect(fields['new 3.1'].value).to eql response.agree_with_early_conciliation_details ? 'yes' : 'no'
            expect(fields['new 3.1 If no, please explain why'].value).to eql response.disagree_conciliation_reason
          end
        end

        def has_employment_details_for?(response, errors: [], indent: 1)
          validate_fields section: :employment, errors: errors, indent: indent do
            expect(fields['3.1'].value).to eql response.agree_with_employment_dates ? 'yes' : 'no'
            expect(fields['3.1 employment started'].value).to eql response.employment_start
            expect(fields['3.1 employment end'].value).to eql response.employment_end
            expect(fields['3.1 disagree'].value).to eql response.disagree_employment
            expect(fields['3.2'].value).to eql response.continued_employment ? 'yes' : 'no'
            expect(fields['3.3'].value).to eql response.agree_with_claimants_description_of_job_or_title ? 'yes' : 'no'
            expect(fields['3.3 if no'].value).to eql response.disagree_claimants_job_or_title ? 'yes' : 'no'
          end
        end

        def has_earnings_for?(response, errors: [], indent: 1)
          validate_fields section: :earnings, errors: errors, indent: indent do
            expect(fields['4.1'].value).to eql response.agree_with_claimants_hours ? 'yes' : 'no'
            expect(fields['4.1 if no'].value).to eql response.queried_hours
            expect(fields['4.2'].value).to eql response.agree_with_earnings_details
            expect(fields['4.2 pay before tax'].value).to eql response.queried_pay_before_tax
            expect(fields['4.2 pay before tax tick box'].value).to eql response.queried_pay_before_tax_period.downcase
            expect(fields['4.2 normal take-home pay'].value).to eql response.queried_take_home_pay
            expect(fields['4.2 normal take-home pay tick box'].value).to eql response.queried_take_home_pay_period.downcase
            expect(fields['4.3 tick box'].value).to eql response.agree_with_claimant_notice ? 'yes' : 'no'
            expect(fields['4.3 if no'].value).to eql response.disagree_claimant_notice_reason
            expect(fields['4.4 tick box'].value).to eql response.agree_with_claimant_pension_benefits ? 'yes' : 'no'
            expect(fields['4.4 if no'].value).to eql response.disagree_claimant_pension_benefits_reason
          end
        end

        def has_response_for?(response, errors: [], indent: 1)
          validate_fields section: :response, errors: errors, indent: indent do
            expect(fields['5.1 tick box'].value).to eql response.defend_claim ? 'yes' : 'no'
            expect(fields['5.1 if yes'].value).to eql response.defend_claim_facts
          end
        end

        def has_contract_claim_for?(response, errors: [], indent: 1)
          validate_fields section: :contract_claim, errors: errors, indent: indent do
            expect(fields['6.2 tick box'].value).to eql response.make_employer_contract_claim ? 'yes' : 'Off'
            expect(fields['6.3'].value).to eql response.claim_information

          end
        end

        def has_representative_for?(representative, errors: [], indent: 1)
          address = representative.address_attributes
          validate_fields section: :representative, errors: errors, indent: indent do
            expect(fields['7.1'].value).to eql representative.name
            expect(fields['7.2'].value).to eql representative.organisation_name
            expect(fields['7.3 number or name'].value).to eql address.building
            expect(fields['7.3 street'].value).to eql address.street
            expect(fields['7.3 town city'].value).to eql address.locality
            expect(fields['7.3 county'].value).to eql address.county
            expect(fields['7.3 postcode'].value).to eql address.post_code
            expect(fields['7.4'].value).to eql representative.dx_number
            expect(fields['7.5 phone number'].value).to eql representative.address_telephone_number
            expect(fields['7.6'].value).to eql representative.mobile_number
            expect(fields['7.7'].value).to eql representative.reference
            expect(fields['7.8 tick box'].value).to eql representative.contact_preference
            expect(fields['7.9'].value).to eql representative.email_address
            expect(fields['7.10'].value).to eql representative.fax_number
          end
        end

        def has_disablity_for?(representative, errors: [], indent: 1)
          validate_fields section: :disability, errors: errors, indent: indent do
            expect(fields['8.1 tick box'].value).to eql representative.disability ? 'yes' : 'no'
            expect(fields['8.1 if yes'].value).to eql representative.disability_information
          end
        end

        private

        attr_accessor :tempfile

        def fields
          @fields ||= form.fields
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


      end
    end
  end
end
