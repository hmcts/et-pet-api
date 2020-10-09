require_relative './base'
require_relative '../../helpers/office_helper'
require_relative '../../helpers/claim_helper'
require_relative './new_claim_email_en'
module EtApi
  module Test
    module GovUkNotifyEmailObjects
      class NewClaimEmailCy < NewClaimEmailEn
        def self.template_reference
          'et1-v1-cy'
        end

        def has_correct_content_for?(input_data, primary_claimant_data, claimants_file, claim_details_file, reference:) # rubocop:disable Naming/PredicateName
        office = office_for(case_number: reference)
        aggregate_failures 'validating content' do
          assert_reference_element(reference)
          expect(has_correct_subject?).to be true
          expect(assert_correct_to_address_for?(input_data)).to be true
          assert_office_information(office)
          assert_submission_date
          assert_claimant(primary_claimant_data)
          expect(attached_pdf_file).to include 'file', 'is_csv'
          if claimants_file.present?
            expect(attached_claimants_file).to include 'file', 'is_csv'
            expect(mail.dig('personalisation', 'has_claimants_file')).to eql 'yes'
          else
            expect(attached_claimants_file).to eq 'Dim ffeil ychwanegol wedi’i llwytho i fyny'
            expect(mail.dig('personalisation', 'has_claimants_file')).to eql 'no'
          end
          if claim_details_file.present?
            expect(attached_info_file).to include 'file', 'is_csv'
            expect(mail.dig('personalisation', 'has_additional_info')).to eql 'yes'
          else
            expect(attached_info_file).to eq 'Dim ffeil ychwanegol wedi’i llwytho i fyny'
            expect(mail.dig('personalisation', 'has_additional_info')).to eql 'no'
          end
        end
        true
        end

        def has_correct_subject? # rubocop:disable Naming/PredicateName
          mail['template_id'] == 'correct-template-id-cy'
        end
      end
    end
  end
end
