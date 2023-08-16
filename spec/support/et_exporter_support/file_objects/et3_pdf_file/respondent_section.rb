require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class RespondentSection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(respondent:)
            respondent = respondent.to_h
            address = respondent[:address_attributes].to_h
            expected_values = {
              name: respondent[:name],
              contact: respondent.fetch(:contact, ''),
              address: a_hash_including(
                building: address[:building],
                street: address[:street],
                locality: address[:locality],
                county: address[:county],
                post_code: address[:post_code].tr(' ', '')
              ),
              address_dx_number: respondent[:dx_number] || '',
              phone_number: respondent[:address_telephone_number] || '',
              mobile_number: respondent[:alt_phone_number] || '',
              contact_preference: respondent.fetch(:contact_preference, nil),
              email_address: respondent.fetch(:email_address, ''),
              fax_number: respondent.fetch(:fax_number, ''),
              allow_video_attendance: respondent[:allow_video_attendance],
              employ_gb: respondent[:organisation_employ_gb].to_s,
              multi_site_gb: respondent[:organisation_more_than_one_site],
              employment_at_site_number: respondent[:employment_at_site_number].to_s
            }
            # @TODO Review this conditional after march 2019 - the welsh pdf should have the contact preference field added
            if template == 'et3-v1-cy'
              expected_values.delete(:contact_preference)
            end
            expect(mapped_field_values).to match(expected_values)
          end
        end
      end
    end
  end
end
