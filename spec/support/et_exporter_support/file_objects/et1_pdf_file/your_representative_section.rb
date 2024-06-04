require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class YourRepresentativeSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(representative:)
            expected_values = {
              name_of_organisation: representative&.organisation_name || '',
              name_of_representative: representative&.name || '',
              post_code: formatted_post_code(representative&.address_attributes&.post_code, optional: representative.nil?) || '',
              dx_number: representative&.dx_number || '',
              telephone_number: representative&.address_telephone_number || '',
              alternative_telephone_number: representative&.mobile_number || '',
              reference: nil, # Should be populated but it isnt yet # @TODO Make reference work in pdf
              email_address: representative&.email_address || '',
              communication_preference: nil # ET1 Doesnt capture this
            }
            expected_values.merge!(address_hash(representative&.address_attributes))
            expect(mapped_field_values).to include expected_values
          end

          private

          def address_hash(address)
            return {} if address.nil?

            if template_has_combined_address_fields?
              {
                address: [address.building, address.street, address.locality, address.county].compact.compact_blank.join("\n")
              }
            else
              {
                building: address.building,
                street: address.street,
                locality: address.locality,
                county: address.county
              }
            end
          end
        end
      end
    end
  end
end
