require_relative 'base'
require_relative '../../helpers/office_helper'
require_relative '../../helpers/claim_helper'
require_relative 'new_claim_email_en'
module EtApi
  module Test
    module GovUkNotifyEmailObjects
      class NewClaimEmailCy < NewClaimEmailEn
        def self.template_reference
          'et1-v1-cy'
        end

        define_site_prism_elements(template_reference)

        def has_correct_content_for?(input_data, primary_claimant_data, claimants_file, claim_details_file, reference:)
          office = office_for(case_number: reference)
          aggregate_failures 'validating content' do
            assert_reference_element(reference)
            expect(has_correct_subject?).to be true
            expect(assert_correct_to_address_for?(input_data)).to be true
            assert_office_information(office)
            assert_submission_date
            assert_claimant(primary_claimant_data)
            expect(attached_pdf_file.value).to be_present
            if claimants_file.present?
              expect(attached_claimants_file.value).to match(/Rydych wedi llwyddo i lwytho hawliad grŵp ar ffurf ffeil csv o'r enw .* gyda'ch hawliad\. Maint y ffeil yw .*./)
            else
              expect(attached_claimants_file.value).to eq 'Dim ffeil ychwanegol wedi’i llwytho i fyny'
            end
            if claim_details_file.present?
              expect(attached_info_file.value).to match(/Rydych wedi llwyddo i lwytho dogfen ychwanegol o’ enw .* gyda’ch hawliad\. Maint y ffeil yw .*\./)
            else
              expect(attached_info_file.value).to eq 'Dim ffeil ychwanegol wedi’i llwytho i fyny'
            end
          end
          true
        end

        def assert_office_information(office)
          expect(tribunal_office.value).to eql 'Cymru, Tribiwnlys Cyflogaeth'
          expect(tribunal_office_contact.email_value).to eql office.email
          expect(tribunal_office_contact.telephone_value).to eql '0300 303 0654'
        end

      end
    end
  end
end
