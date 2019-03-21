require_relative './base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class HeaderSection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(response:) # rubocop:disable Naming/PredicateName
            # @TODO Review this conditional after march 2019 - once the pdf has been sorted, it should have the date_received and rtf fields
            if template == 'et3-v1-cy'
              expected_values = {
                case_number: response[:case_number]
              }
              expect(mapped_field_values).to eql(expected_values)
            else
              expected_values = {
                case_number: response[:case_number],
                date_received: formatted_date(Time.zone.now),
                rtf: response[:additional_information_key].present?
              }
              expect(mapped_field_values).to eql(expected_values).or(include(expected_values.merge(date_received: formatted_date(1.hour.ago))))
            end
          end
        end
      end
    end
  end
end
