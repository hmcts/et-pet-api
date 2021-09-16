require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class AdditionalRespondentsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          EMPTY_RESPONDENT = {
            name: '',
            address: { building: '', street: '', locality: '', county: '', post_code: '', telephone_number: ''}.freeze,
            acas: { have_acas: false, acas_number: ''}.freeze
          }.freeze

          def has_contents_for?(respondents:) # rubocop:disable Naming/PredicateName
            # claimant.title is a selection of options - in this case we are interested in the key thats all - do not translate it
            expected_values = {}
            2.times do |idx|
              respondents_idx = 3 + idx
              if respondents[respondents_idx].present?
                expected_values[:"respondent#{4 +  idx}"] = {
                  name: respondents[respondents_idx].name,
                  address: {
                    building: respondents[respondents_idx].address_attributes.building,
                    street: respondents[respondents_idx].address_attributes.street,
                    locality: respondents[respondents_idx].address_attributes.locality,
                    county: respondents[respondents_idx].address_attributes.county,
                    post_code: formatted_post_code(respondents[respondents_idx].address_attributes.post_code),
                    telephone_number: respondents[respondents_idx].address_telephone_number
                  },
                  acas: {
                    have_acas: respondents[respondents_idx].acas_certificate_number.present?,
                    acas_number: respondents[respondents_idx].acas_certificate_number || ''
                  }
                }
              else
                expected_values[:"respondent#{4 + idx}"] = EMPTY_RESPONDENT
              end
            end
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
