require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class MultipleCasesSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claim:)
            # claimant.title is a selection of options - in this case we are interested in the key thats all - do not translate it
            expected_values = {
                have_similar_claims: claim.other_known_claimant_names&.present?,
                other_claimants: claim.other_known_claimant_names || ''
            }
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
