require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class WhatDoYouWantSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(claim:)
            expected_values = {
                prefer_re_instatement: claim.desired_outcomes.include?('reinstated_employment_and_compensation'),
                prefer_re_engagement: claim.desired_outcomes.include?('new_employment_and_compensation'),
                prefer_compensation: claim.desired_outcomes.include?('compensation_only'),
                prefer_recommendation: claim.desired_outcomes.include?('tribunal_recommendation'),
                compensation: claim.other_outcome || ''
            }
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
