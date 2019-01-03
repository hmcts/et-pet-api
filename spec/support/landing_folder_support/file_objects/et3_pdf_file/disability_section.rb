require_relative './base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class DisabilitySection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(respondent:)
            expected_values = {
              has_disability: respondent[:disability],
              information: respondent[:disability_information] || ''
            }
            expect(mapped_field_values).to include(expected_values)
          end
        end
      end
    end
  end
end
