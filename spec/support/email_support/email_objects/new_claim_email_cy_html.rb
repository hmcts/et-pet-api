require_relative './base'
require_relative '../../helpers/office_helper'
module EtApi
  module Test
    module EmailObjects
      class NewClaimEmailCyHtml < NewClaimEmailEnHtml
        def self.find(repo: ActionMailer::Base.deliveries, reference:)
          instances = repo.map { |mail| new(mail) }
          instances.detect { |instance| instance.has_correct_subject? && instance.has_reference_element?(reference) }
        end

        def self.template_reference
          'et1-v1-cy'
        end

        define_site_prism_elements(template_reference)

        def assert_office_information(office)
          expect(office_information).to have_office_summary(text: "Cymru, Tribiwnlys Cyflogaeth, 3ydd Llawr, Llys Ynadon Caerdydd a’r Fro, Plas Fitzalan, Caerdydd, CF24 0RA")
        end
      end
    end
  end
end
