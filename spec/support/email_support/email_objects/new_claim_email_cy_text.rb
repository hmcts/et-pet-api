require_relative './base'
require_relative '../../helpers/office_helper'
require_relative './new_claim_email_en_text'
module EtApi
  module Test
    module EmailObjects
      class NewClaimEmailCyText < NewClaimEmailEnText
        def self.find(repo: ActionMailer::Base.deliveries, reference:)
          instances = repo.map { |delivery| new(delivery) }
          instances.detect { |instance| instance.has_correct_subject? && instance.has_reference?(reference) }
        end

        def self.template_reference
          'et1-v1-cy'
        end

        def assert_office_information(office)
          return if lines.any? { |l| l.strip =~ %r{Swyddfa tribiwnlys: \s*Cymru, Tribiwnlys Cyflogaeth, 3ydd Llawr, Llys Ynadon Caerdydd a’r Fro, Plas Fitzalan, Caerdydd, CF24 0RA} }

          raise Capybara::ElementNotFound.new("The office information line was not found for #{office.name}")
        end
      end
    end
  end
end
