require_relative './base'
require_relative '../../../helpers/office_helper'
module EtApi
  module Test
    module FileObjects
      module Et1PdfFileSection
        class OfficialUseOnlySection < EtApi::Test::FileObjects::Et1PdfFileSection::Base
          include EtApi::Test::OfficeHelper

          def has_contents_for?(claim:, respondent:)
            office_data = office_from_respondent(respondent)
            expected_values = {
              tribunal_office: office_data['name'],
              date_received: formatted_date(ActiveSupport::TimeZone[claim.time_zone].parse(claim.date_of_receipt))
            }
            expect(mapped_field_values).to include expected_values
          end

        end
      end
    end
  end
end
