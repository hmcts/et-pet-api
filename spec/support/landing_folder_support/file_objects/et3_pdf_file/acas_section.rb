require_relative './base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class AcasSection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(response:)
            expected_values = {
              agree: response[:agree_with_early_conciliation_details].present?,
              disagree_explanation: response[:disagree_conciliation_reason] || ''
            }
            expect(mapped_field_values).to include(expected_values)
          end
        end
      end
    end
  end
end
