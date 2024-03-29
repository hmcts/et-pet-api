require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class ClaimantSection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(response:)
            expected_values = {
              claimants_name: response[:claimants_name] || ''
            }
            expect(mapped_field_values).to include(expected_values)
          end
        end
      end
    end
  end
end
