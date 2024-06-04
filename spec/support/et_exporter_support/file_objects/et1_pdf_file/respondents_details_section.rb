# frozen_string_literal: true
require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class RespondentsDetailsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          LEGACY_EMPTY_RESPONDENT = {
            name: '',
            address: { building: '', street: '', locality: '', county: '', post_code: '', telephone_number: '' }.freeze,
            acas: { have_acas: nil, acas_number: '', no_acas_number_reason: nil }.freeze
          }.freeze

          EMPTY_RESPONDENT = {
            name: '',
            address: { details: '', post_code: '' }.freeze,
            acas: { have_acas: nil, acas_number: '', no_acas_number_reason: nil }.freeze
          }.freeze

          def has_contents_for?(respondents:)
            expected_values = {
              name: respondents.first.name,
              address: address_hash(respondents.first.address_attributes),
              acas: {
                have_acas: respondents.first.acas_certificate_number.present?,
                acas_number: respondents.first.acas_certificate_number || '',
                no_acas_number_reason: respondents.first.acas_exemption_code
              },
              different_address: address_hash(respondents.first.work_address_attributes, optional_post_code: true),
              additional_respondents: respondents.length > 1,
              respondent2: extra_respondent_for(respondents[1]),
              respondent3: extra_respondent_for(respondents[2])
            }
            expect(mapped_field_values).to include expected_values
          end

          private

          def extra_respondent_for(resp)
            return empty_respondent if resp.nil?

            {
              name: resp.name,
              address: address_hash(resp.address_attributes),
              acas: {
                have_acas: resp.acas_certificate_number&.present?,
                acas_number: resp.acas_certificate_number || '',
                no_acas_number_reason: resp.acas_exemption_code
              }

            }
          end

          def empty_respondent
            template_has_combined_address_fields? ? EMPTY_RESPONDENT : LEGACY_EMPTY_RESPONDENT
          end

          def address_hash(address, optional_post_code: false)
            if template_has_combined_address_fields?
              {
                details: [address.building, address.street, address.locality, address.county].compact.compact_blank.join("\n"),
                post_code: formatted_post_code(address.post_code, optional: optional_post_code) || ''
              }
            else
              {
                building: address.building,
                street: address.street,
                locality: address.locality,
                county: address.county,
                post_code: formatted_post_code(address.post_code, optional: optional_post_code) || '',
                telephone_number: an_instance_of(String)
              }
            end
          end
        end
      end
    end
  end
end
