require 'rspec/matchers'
require_relative './base_pdf_file'
module EtApi
  module Test
    module FileObjects
      class Et3PdfFile < BasePdfFile # rubocop:disable Metrics/ClassLength
        include RSpec::Matchers

        def has_correct_contents_for?(response:, respondent:, representative:, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
            Et3PdfFileSection::HeaderSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::ClaimantSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::RespondentSection.new(field_values, lookup_root, template: template).has_contents_for?(respondent: respondent)
            Et3PdfFileSection::AcasSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::EmploymentDetailsSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::EarningsSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::ResponseSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::ContractClaimSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::RepresentativeSection.new(field_values, lookup_root, template: template).has_contents_for?(representative: representative)
            Et3PdfFileSection::DisabilitySection.new(field_values, lookup_root, template: template).has_contents_for?(respondent: respondent)
        end

        def has_correct_contents_from_db_for?(response:, errors: [], indent: 1)
          respondent = response.respondent.as_json(include: :address).symbolize_keys
          representative = response.representative.try(:as_json, include: :address).try(:symbolize_keys)
          respondent[:address_attributes] = respondent.delete(:address).symbolize_keys
          representative[:address_attributes] = representative.delete(:address).symbolize_keys unless representative.nil?
          response = response.as_json.symbolize_keys.merge(additional_information_key: response.additional_information_rtf_file? ? 'canbeanything' : nil)
          has_correct_contents_for?(response: response, respondent: respondent, representative: representative, errors: errors, indent: indent)
        end
      end
    end
  end
end
