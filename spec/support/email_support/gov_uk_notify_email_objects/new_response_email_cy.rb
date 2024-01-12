require_relative 'base'
require_relative '../../helpers/office_helper'
require_relative '../../helpers/response_helper'
require_relative 'new_response_email_en'
module EtApi
  module Test
    module GovUkNotifyEmailObjects
      class NewResponseEmailCy < NewResponseEmailEn
        def self.template_reference
          'et3-v2-cy'
        end

        define_site_prism_elements(template_reference)
      end
    end
  end
end
