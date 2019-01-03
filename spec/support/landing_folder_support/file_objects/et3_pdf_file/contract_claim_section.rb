require_relative './base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class ContractClaimSection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(response:)
            expected_values = {
              make_employer_contract_claim: response[:make_employer_contract_claim],
              information: response[:claim_information] || ''
            }
            expect(mapped_field_values).to include(expected_values)
          end
        end
      end
    end
  end
end
