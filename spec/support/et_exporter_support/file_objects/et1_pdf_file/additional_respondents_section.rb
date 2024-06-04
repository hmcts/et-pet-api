require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class AdditionalRespondentsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
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
            # claimant.title is a selection of options - in this case we are interested in the key thats all - do not translate it
            expected_values = {}
            2.times do |idx|
              respondents_idx = 3 + idx
              expected_values[:"respondent#{4 + idx}"] = if respondents[respondents_idx].present?
                                                           {
                                                             name: respondents[respondents_idx].name,
                                                             address: address_hash(respondents[respondents_idx].address_attributes),
                                                             acas: {
                                                               have_acas: respondents[respondents_idx].acas_certificate_number&.present?,
                                                               acas_number: respondents[respondents_idx].acas_certificate_number || '',
                                                               no_acas_number_reason: respondents[respondents_idx].acas_exemption_code
                                                             }
                                                           }
                                                         else
                                                           template_has_combined_address_fields? ? EMPTY_RESPONDENT : LEGACY_EMPTY_RESPONDENT
                                                         end
            end
            expect(mapped_field_values).to include expected_values
          end

          private

          def address_hash(address, optional_post_code: false)
            if template_has_combined_address_fields?
              {
                details: [address.building, address.street, address.locality, address.county].compact.compact_blank.join("\n"),
                post_code: formatted_post_code(address.post_code, optional: optional_post_code)
              }
            else
              {
                building: address.building,
                street: address.street,
                locality: address.locality,
                county: address.county,
                post_code: formatted_post_code(address.post_code, optional: optional_post_code),
                telephone_number: an_instance_of(String)
              }
            end
          end

        end
      end
    end
  end
end
