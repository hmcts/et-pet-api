require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class InformationToRegulatorsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claim:)
            expected_values = {
              whistle_blowing: claim.send_claim_to_whistleblowing_entity.present?
            }
            if template_has_combined_address_fields?
              expected_values.merge!(regulator_name: claim.whistleblowing_regulator_name || '')
            end
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
