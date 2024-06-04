require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class YourDetailsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claimant:)
            date_of_birth = formatted_date(claimant.date_of_birth, optional: true)&.split('/') || ['', '', '']
            expected_values = {
              title: claimant.title,
              first_name: claimant.first_name,
              last_name: claimant.last_name,
              dob_day: date_of_birth[0],
              dob_month: date_of_birth[1],
              dob_year: date_of_birth[2],
              gender: claimant.gender,
              post_code: formatted_post_code(claimant.address_attributes.post_code),
              telephone_number: claimant.address_telephone_number,
              alternative_telephone_number: claimant.mobile_number,
              email_address: claimant.email_address,
              correspondence: claimant.contact_preference,
              allow_video_attendance: claimant.allow_video_attendance
            }
            if template_has_combined_address_fields?
              expected_values[:address] = [claimant.address_attributes.building, claimant.address_attributes.street, claimant.address_attributes.locality, claimant.address_attributes.county].join("\n")
            else
              expected_values.merge! building: claimant.address_attributes.building,
                                     street: claimant.address_attributes.street,
                                     locality: claimant.address_attributes.locality,
                                     county: claimant.address_attributes.county,
                                     telephone_number: an_instance_of(String)

            end

            if template_has_phone_or_video_attendance_fields?
              expected_values.merge! allow_phone_attendance: claimant.allow_phone_attendance,
                                     no_phone_or_video_attendance: claimant.allow_video_attendance == false && claimant.allow_phone_attendance == false

            end
            expect(mapped_field_values).to include expected_values
          end

        end
      end
    end
  end
end
