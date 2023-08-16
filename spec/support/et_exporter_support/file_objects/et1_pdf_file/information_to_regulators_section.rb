require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class InformationToRegulatorsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claim:) # rubocop:disable Lint/UnusedMethodArgument
            {
              # @TODO commented out for the reason of having an apostrophe supposedly causing a change in the data from false to nil going through pdftk
              # whistle_blowing: claim.send_claim_to_whistleblowing_entity.present?,
            }
            # expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
