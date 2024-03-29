require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class AdditionalInformationSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claim:)
            expected_values = {
              additional_information: claim.miscellaneous_information
            }
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
