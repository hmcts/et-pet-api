require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class MultipleClaimFormSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claimants:, assert_missing: true)
            if claimants.length > 1
              expected_values = (1..6).reduce({}) do |acc, claimant_number|
                claimant = claimants[claimant_number]
                acc[:"additional_claimant_#{claimant_number}"] = {
                  title: claimant&.title,
                  first_name: claimant&.first_name || '',
                  last_name: claimant&.last_name || '',
                  dob_day: formatted_date(claimant&.date_of_birth, optional: true)&.split('/')&.at(0) || '',
                  dob_month: formatted_date(claimant&.date_of_birth, optional: true)&.split('/')&.at(1) || '',
                  dob_year: formatted_date(claimant&.date_of_birth, optional: true)&.split('/')&.at(2) || '',
                  building: claimant&.address_attributes&.building || '',
                  street: claimant&.address_attributes&.street || '',
                  locality: claimant&.address_attributes&.locality || '',
                  county: claimant&.address_attributes&.county || '',
                  post_code: formatted_post_code(claimant&.address_attributes&.post_code, optional: claimant.nil?) || ''

                }
                acc
              end
              expect(mapped_field_values).to include expected_values
            elsif assert_missing
              assert_is_missing
            end
          end
        end
      end
    end
  end
end
