require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class YourRepresentativeSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(representative:)
            expected_values = {
                name_of_organisation: representative&.organisation_name || '',
                name_of_representative: representative&.name || '',
                building: representative&.address_attributes&.building || '',
                street: representative&.address_attributes&.street || '',
                locality: representative&.address_attributes&.locality || '',
                county: representative&.address_attributes&.county || '',
                post_code: formatted_post_code(representative&.address_attributes&.post_code, optional: representative.nil?) || '',
                dx_number: representative&.dx_number || '',
                telephone_number: representative&.address_telephone_number || '',
                alternative_telephone_number: representative&.mobile_number || '',
                reference: nil, # Should be populated but it isnt yet # @TODO Make reference work in pdf
                email_address: representative&.email_address || '',
                communication_preference: nil, # ET1 Doesnt capture this
                fax_number: nil # ET1 Doesnt capture this
            }
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
