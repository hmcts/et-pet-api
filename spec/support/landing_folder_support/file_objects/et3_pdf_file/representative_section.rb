require_relative './base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class RepresentativeSection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(representative:)
            return has_no_representative? if representative.nil?
            address = representative[:address_attributes] || empty_address_attributes
            expected_values = {
              name: representative[:name] || '',
              organisation_name: representative[:organisation_name] || '',
              address: a_hash_including(
                building: address[:building],
                street: address[:street],
                locality: address[:locality],
                county: address[:county],
                post_code: address[:post_code].tr(' ', '')
              ),
              dx_number: representative[:dx_number] || '',
              phone_number: representative[:address_telephone_number] || '',
              mobile_number: representative[:mobile_number] || '',
              reference: representative[:reference] || '',
              contact_preference: representative[:contact_preference],
              email_address: representative[:email_address] || '',
              fax_number: representative[:fax_number] || ''
            }
            expect(mapped_field_values).to include(expected_values)
          end

          private

          def empty_address_attributes
            {
              building: '',
              street: '',
              locality: '',
              county: '',
              post_code: ''
            }
          end

          def has_no_representative?
            expected_values = {
              name: '',
              organisation_name: '',
              address: a_hash_including(
                building: '',
                street: '',
                locality: '',
                county: '',
                post_code: ''
              ),
              dx_number: '',
              phone_number: '',
              mobile_number: '',
              reference: '',
              contact_preference: nil,
              email_address: '',
              fax_number: ''
            }
            expect(mapped_field_values).to include(expected_values)
          end
        end
      end
    end
  end
end
