require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class YourDetailsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claimant:)
            expected_values = {
                title: title_for(claimant[:title]),
                first_name: claimant[:first_name],
                last_name: claimant[:last_name],
                dob_day: date_for(claimant[:date_of_birth]).split('/')[0],
                dob_month: date_for(claimant[:date_of_birth]).split('/')[1],
                dob_year: date_for(claimant[:date_of_birth]).split('/')[2],
                gender: claimant[:gender],
                building: claimant.dig(:address, :building),
                street: claimant.dig(:address, :street),
                locality: claimant.dig(:address, :locality),
                county: claimant.dig(:address, :county),
                post_code: post_code_for(claimant.dig(:address, :post_code)),
                telephone_number: claimant[:address_telephone_number],
                alternative_telephone_number: claimant[:mobile_number],
                email_address: claimant[:email_address],
                correspondence: claimant[:contact_preference]
            }
            expect(mapped_field_values).to include expected_values
          end

        end
      end
    end
  end
end
