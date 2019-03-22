require 'rspec/matchers'
require_relative './base_pdf_file'

module EtApi
  module Test
    module FileObjects
      # Represents the ET3 PDF file and provides assistance in validating its contents
      class Et1PdfFile < BasePdfFile
        def has_correct_contents_for?(claim:, claimants:, respondents:, representative:) # rubocop:disable Naming/PredicateName
          Et1PdfFileSection::YourDetailsSection.new(field_values, lookup_root, template: template).has_contents_for?(claimant: claimants.first)
          Et1PdfFileSection::RespondentsDetailsSection.new(field_values, lookup_root, template: template).has_contents_for?(respondents: respondents)
          Et1PdfFileSection::MultipleCasesSection.new(field_values, lookup_root, template: template).has_contents_for?(claim: claim)
          Et1PdfFileSection::NotYourEmployerSection.new(field_values, lookup_root, template: template).has_contents_for?
          Et1PdfFileSection::EmploymentDetailsSection.new(field_values, lookup_root, template: template).has_contents_for?(employment: claim.employment_details)
          Et1PdfFileSection::EarningsAndBenefitsSection.new(field_values, lookup_root, template: template).has_contents_for?(employment: claim.employment_details)
          Et1PdfFileSection::WhatHappenedSinceSection.new(field_values, lookup_root, template: template).has_contents_for?(employment: claim.employment_details)
          Et1PdfFileSection::TypeAndDetailsSection.new(field_values, lookup_root, template: template).has_contents_for?(claim: claim)
          Et1PdfFileSection::WhatDoYouWantSection.new(field_values, lookup_root, template: template).has_contents_for?(claim: claim)
          Et1PdfFileSection::InformationToRegulatorsSection.new(field_values, lookup_root, template: template).has_contents_for?(claim: claim)
          Et1PdfFileSection::YourRepresentativeSection.new(field_values, lookup_root, template: template).has_contents_for?(representative: representative)
          Et1PdfFileSection::DisabilitySection.new(field_values, lookup_root, template: template).has_contents_for?(claimant: claimants.first)
          Et1PdfFileSection::AdditionalRespondentsSection.new(field_values, lookup_root, template: template).has_contents_for?(respondents: respondents)
          Et1PdfFileSection::FinalCheckSection.new(field_values, lookup_root, template: template).has_contents_for?
          Et1PdfFileSection::AdditionalInformationSection.new(field_values, lookup_root, template: template).has_contents_for?(claim: claim)
          true
        end

        def has_correct_contents_from_db_for?(claim:, errors: [], indent: 1)
          respondents = respondents_json(claim)
          claimants = claimants_json(claim)
          representative = representative_json(claim)
          claim = claim_json(claim)
          has_correct_contents_for?(claim: claim, claimants: claimants, respondents: respondents, representative: representative)
        end

        private

        def claim_json(claim)
          json = claim.as_json.symbolize_keys
          OpenStruct.new(json).freeze
        end

        def representative_json(claim)
          representative = claim.primary_representative
          return nil if representative.nil?

          OpenStruct.new(representative.as_json(include: :address).symbolize_keys.tap { |rep| rep[:address_attributes] = OpenStruct.new(rep.delete(:address).symbolize_keys) }).freeze
        end

        def respondents_json(claim)
          respondents = [claim.primary_respondent.as_json(include: [:address, :work_address]).symbolize_keys]
          respondents.concat claim.secondary_respondents.map { |r| r.as_json(include: [:address, :work_address]).symbolize_keys }
          respondents.map do |r|
            r[:address_attributes] = OpenStruct.new(r.delete(:address)).freeze
            r[:work_address_attributes] = OpenStruct.new(r.delete(:work_address) || {}).freeze
            OpenStruct.new(r).freeze
          end
        end

        def claimants_json(claim)
          claimants = [claim.primary_claimant.as_json(include: :address).symbolize_keys]
          claimants.concat claim.secondary_claimants.map { |r| r.as_json(include: :address).symbolize_keys }
          claimants.map do |c|
            c[:address_attributes] = OpenStruct.new(c.delete(:address)).freeze
            OpenStruct.new(c).freeze
          end
        end
      end
    end
  end
end
