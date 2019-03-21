# frozen_string_literal: true
require_relative './base.rb'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class RespondentsDetailsSection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          EMPTY_RESPONDENT = {
            name: '',
            address: { building: '', street: '', locality: '', county: '', post_code: '', telephone_number: ''}.freeze,
            acas: { have_acas: nil, acas_number: ''}.freeze
          }.freeze
          def has_contents_for?(respondents:)
            expected_values = {
                name: respondents.first.name,
                address: {
                    building: respondents.first.address_attributes.building,
                    street: respondents.first.address_attributes.street,
                    locality: respondents.first.address_attributes.locality,
                    county: respondents.first.address_attributes.county,
                    post_code: formatted_post_code(respondents.first.address_attributes.post_code),
                    telephone_number: respondents.first.address_telephone_number
                },
                acas: {
                    have_acas: respondents.first.acas_certificate_number.present?,
                    acas_number: respondents.first.acas_certificate_number || ''
                },
                different_address: {
                    building: respondents.first.work_address_attributes&.building || '',
                    street: respondents.first.work_address_attributes&.street || '',
                    locality: respondents.first.work_address_attributes&.locality || '',
                    county: respondents.first.work_address_attributes&.county || '',
                    post_code: formatted_post_code(respondents.first.work_address_attributes&.post_code, optional: true) || '',
                    telephone_number: respondents.first.work_address_telephone_number || ''
                },
                additional_respondents: respondents.length > 1,
                respondent2: extra_respondent_for(respondents[1]),
                respondent3: extra_respondent_for(respondents[2])
            }
            expect(mapped_field_values).to include expected_values
          end


          private
          
          def extra_respondent_for(resp)
            return EMPTY_RESPONDENT if resp.nil?
            
            {
              name: resp.name,
              address: {
                building: resp.address_attributes.building,
                street: resp.address_attributes.street,
                locality: resp.address_attributes.locality,
                county: resp.address_attributes.county,
                post_code: formatted_post_code(resp.address_attributes.post_code),
                telephone_number: resp.telephone_number || ''
              },
              acas: {
                have_acas: resp.acas_certificate_number.present?,
                acas_number: resp.acas_certificate_number
              }
              
            }
          end
        end
      end
    end
  end
end
