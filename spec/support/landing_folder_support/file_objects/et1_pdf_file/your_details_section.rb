require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class YourDetailsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claimant:)
            expected_values = {
                title: claimant.title,
                first_name: claimant.first_name,
                last_name: claimant.last_name,
                dob_day: formatted_date(claimant.date_of_birth).split('/')[0],
                dob_month: formatted_date(claimant.date_of_birth).split('/')[1],
                dob_year: formatted_date(claimant.date_of_birth).split('/')[2],
                gender: claimant.gender,
                building: claimant.address_attributes.building,
                street: claimant.address_attributes.street,
                locality: claimant.address_attributes.locality,
                county: claimant.address_attributes.county,
                post_code: formatted_post_code(claimant.address_attributes.post_code),
                telephone_number: claimant.address_telephone_number,
                alternative_telephone_number: claimant.mobile_number,
                email_address: claimant.email_address,
                correspondence: claimant.contact_preference
            }
            expect(mapped_field_values).to include expected_values
          end

        end
      end
    end
  end
end
