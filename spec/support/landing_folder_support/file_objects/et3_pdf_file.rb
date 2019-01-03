require_relative 'base'
require_relative '../../helpers/office_helper'
module EtApi
  module Test
    module FileObjects
      class Et3PdfFile < Base # rubocop:disable Metrics/ClassLength
        include RSpec::Matchers

        def has_correct_contents_for?(response:, respondent:, representative:, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
            Et3PdfFileSection::HeaderSection.new(tempfile).has_contents_for?(response: response)
            Et3PdfFileSection::ClaimantSection.new(tempfile).has_contents_for?(response: response)
            Et3PdfFileSection::RespondentSection.new(tempfile).has_contents_for?(respondent: respondent)
            Et3PdfFileSection::AcasSection.new(tempfile).has_contents_for?(response: response)
            Et3PdfFileSection::EmploymentDetailsSection.new(tempfile).has_contents_for?(response: response)
            Et3PdfFileSection::EarningsSection.new(tempfile).has_contents_for?(response: response)
            Et3PdfFileSection::ResponseSection.new(tempfile).has_contents_for?(response: response)
            Et3PdfFileSection::ContractClaimSection.new(tempfile).has_contents_for?(response: response)
            Et3PdfFileSection::RepresentativeSection.new(tempfile).has_contents_for?(representative: representative)
            Et3PdfFileSection::DisabilitySection.new(tempfile).has_contents_for?(respondent: respondent)
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
