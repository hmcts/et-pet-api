require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class ResponseSection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(response:)
            expected_values = {
              defend_claim: response[:defend_claim],
              defend_claim_facts: response[:defend_claim_facts] || ''
            }
            expect(mapped_field_values).to include(expected_values)
          end
        end
      end
    end
  end
end
