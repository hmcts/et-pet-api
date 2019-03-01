require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class DisabilitySection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claimant:)
            expected_values = {
                has_special_needs: claimant.special_needs.present?,
                special_needs: claimant.special_needs || ''
            }
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
