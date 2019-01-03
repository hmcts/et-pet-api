require_relative './base'
module EtApi
  module Test
    module FileObjects
      module Et3PdfFileSection
        class HeaderSection < ::EtApi::Test::FileObjects::Et3PdfFileSection::Base
          def has_contents_for?(response:)
            expected_values = {
              case_number: response[:case_number],
              date_received: date_for(Time.zone.now),
              rtf: response[:additional_information_key].present? ? true : nil
            }
            expect(mapped_field_values).to include(expected_values).or(include(expected_values.merge(date_received: date_for(1.hour.ago))))
          end
        end
      end
    end
  end
end
