require_relative './base'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class NotYourEmployerSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          # Note - I have included this for completeness - but I do not think the field ever gets populated
          def has_contents_for?
            expected_values = {
              claim_type: nil
            }
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
