require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class WhatHappenedSinceSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          def has_contents_for?(employment:)
            if employment.present?
              expected_values = {
                  have_another_job: employment['found_new_job'],
                  start_date: formatted_date(employment['new_job_start_date'], optional: true) || '',
                  salary: employment['new_job_gross_pay'].to_s
              }
            else
              expected_values = {
                  have_another_job: '',
                  start_date: '',
                  salary: ''
              }
            end
            expect(mapped_field_values).to include expected_values
          end
        end
      end
    end
  end
end
