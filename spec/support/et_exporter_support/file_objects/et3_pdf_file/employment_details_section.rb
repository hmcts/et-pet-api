require_relative 'base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class EmploymentDetailsSection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(response:)
            return has_contents_for_pre_v3?(response: response) if template_version < 3

            expected_values = {
              agree_with_dates: response[:agree_with_employment_dates],

              employment_start_day: response[:employment_start].nil? ? '' : formatted_date(response[:employment_start]).split('/')[0],
              employment_start_month: response[:employment_start].nil? ? '' : formatted_date(response[:employment_start]).split('/')[1],
              employment_start_year: response[:employment_start].nil? ? '' : formatted_date(response[:employment_start]).split('/')[2],
              employment_end_day: response[:employment_end].nil? ? '' : formatted_date(response[:employment_end]).split('/')[0],
              employment_end_month: response[:employment_end].nil? ? '' : formatted_date(response[:employment_end]).split('/')[1],
              employment_end_year: response[:employment_end].nil? ? '' : formatted_date(response[:employment_end]).split('/')[2],
              disagree_with_dates_reason: response[:disagree_employment] || '',
              continuing: response[:continued_employment],
              agree_with_job_title: response[:agree_with_claimants_description_of_job_or_title],
              correct_job_title: response[:disagree_claimants_job_or_title] || ''
            }
            expect(mapped_field_values).to include(expected_values)
          end

          private

          def has_contents_for_pre_v3?(response:)
            expected_values = {
              agree_with_dates: response[:agree_with_employment_dates],
              employment_start: response[:employment_start].nil? ? '' : formatted_date(response[:employment_start]),
              employment_end: response[:employment_end].nil? ? '' : formatted_date(response[:employment_end]),
              disagree_with_dates_reason: response[:disagree_employment] || '',
              continuing: response[:continued_employment],
              agree_with_job_title: response[:agree_with_claimants_description_of_job_or_title],
              correct_job_title: response[:disagree_claimants_job_or_title] || ''
            }
            expect(mapped_field_values).to include(expected_values)
          end
        end
      end
    end
  end
end
