require 'rspec/matchers'
require_relative './et3_pdf_file'
module EtApi
  module Test
    module FileObjects
      class Et3PdfFileV1 < Et3PdfFile # rubocop:disable Metrics/ClassLength

        def has_correct_contents_for?(response:, respondent:, representative:, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
            Et3PdfFileSection::HeaderSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::ClaimantSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::RespondentSectionV1.new(field_values, lookup_root, template: template).has_contents_for?(respondent: respondent)
            Et3PdfFileSection::AcasSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::EmploymentDetailsSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::EarningsSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::ResponseSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::ContractClaimSection.new(field_values, lookup_root, template: template).has_contents_for?(response: response)
            Et3PdfFileSection::RepresentativeSection.new(field_values, lookup_root, template: template).has_contents_for?(representative: representative)
            Et3PdfFileSection::DisabilitySection.new(field_values, lookup_root, template: template).has_contents_for?(respondent: respondent)
        end
      end
    end
  end
end
