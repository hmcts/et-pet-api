require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class AdditionalInformationSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claim:) # rubocop:disable Naming/PredicateName
            expected_values = {
              additional_information: claim.other_important_details
            }
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
