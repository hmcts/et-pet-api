require_relative 'base'
require_relative '../../helpers/office_helper'
module EtApi
  module Test
    module FileObjects
      class Et3TxtFile < Base # rubocop:disable Metrics/ClassLength
        include RSpec::Matchers
        include ::EtApi::Test::OfficeHelper

        def initialize(*)
          super
          self.contents = tempfile.readlines("\r\n").map { |l| l.gsub(/\r\n\z/, '') }
        end

        def has_correct_encoding?(errors: [], indent: 1)
          expect(tempfile.path).to have_file_encoding('unknown-8bit').or have_file_encoding('us-ascii')
          true
        rescue RSpec::Expectations::ExpectationNotMetError => err
          errors.concat(err.message.lines.map { |l| "#{'  ' * indent}#{l.gsub(/\n\z/, '')}" })
          false
        end

        def has_correct_file_structure?(errors: []) # rubocop:disable Naming/PredicateName
          has_header_section?(errors: errors)
          has_intro_section?(errors: errors)
          has_claimant_section?(errors: errors)
          has_organisation_section?(errors: errors)
          has_representative_section?(errors: errors)
          has_footer_section?(errors: errors)
          errors.empty?
        end

        def has_section?(section:, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          section_range = send(:"#{section}_section")
          if section_range.nil?
            errors << "Could not find a '#{section.to_s.humanize}' section"
            return nil
          end
          lines = contents.slice(section_range)
          aggregate_failures "Match content against schema for '#{section.to_s.humanize}'" do
            yield(lines)
          end
          true
        rescue RSpec::Expectations::ExpectationNotMetError => err
          errors << "Missing or invalid '#{section.to_s.humanize}' section"
          errors.concat(err.message.lines.map { |l| "#{'  ' * indent}#{l.gsub(/\n\z/, '')}" })
          false
        end

        def has_header_section?(errors: [], indent: 1, **matcher_overrides) # rubocop:disable Naming/PredicateName
          matchers = header_matchers.merge(matcher_overrides)
          has_section?(section: :header, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql 'ET3 - Response to an Employment Tribunal claim'
            expect(lines[1]).to eql ''
            expect(lines[2]).to eql 'For Office Use'
            expect(lines[3]).to eql ""
            expect(lines[4]).to start_with("Received at ET: ").and(matchers[:received_at])
            expect(lines[5]).to start_with("Case Number: ").and(matchers[:case_number])
            expect(lines[6]).to eql "Code:"
            expect(lines[7]).to eql "Initials:"
            expect(lines[8]).to eql ""
            expect(lines[9]).to start_with "Online Submission Reference: "
            expect(lines[10]).to eql ""
            expect(lines[11]).to eql "FormVersion: 2"
            expect(lines[12]).to eql ""
          end
        end

        def has_intro_section?(errors: [], indent: 1, **matcher_overrides) # rubocop:disable Naming/PredicateName
          matchers = intro_matchers.merge(matcher_overrides)
          has_section?(section: :intro, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql '## Intro: '
            expect(lines[1]).to eql ''
            expect(lines[2]).to start_with('**In the claim of: ').and(matchers[:claimants_name])
            expect(lines[3]).to start_with('**Case number: ').and(matchers[:case_number])
            expect(lines[4]).to start_with('**Tribunal office: ').and(matchers[:office_email])
            expect(lines[5]).to eql ''
          end
        end

        def has_claimant_section?(errors: [], indent: 1, **matcher_overrides) # rubocop:disable Naming/PredicateName
          matchers = claimant_matchers.merge(matcher_overrides)
          has_section?(section: :claimant, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 1: Claimant's name"
            expect(lines[1]).to eql ""
            expect(lines[2]).to start_with("~1.1 Claimant's name: ").and(matchers[:name])
            expect(lines[3]).to eql ""
          end
        end

        def has_organisation_section?(errors: [], indent: 1, **matcher_overrides) # rubocop:disable Naming/PredicateName
          matchers = organisation_matchers.merge(matcher_overrides)
          has_section?(section: :organisation, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 2: Your organisation's details"
            expect(lines[1]).to eql ""
            expect(lines[2]).to start_with("~2.1 Name of your organisation: ").and(matchers[:name])
            expect(lines[3]).to start_with("Contact name: ").and(matchers[:contact])
            expect(lines[4]).to eql "~2.2 Address"
            expect(lines[5]).to start_with("Address 1: ").and(matchers[:address][:building])
            expect(lines[6]).to start_with("Address 2: ").and(matchers[:address][:street])
            expect(lines[7]).to start_with("Address 3: ").and(matchers[:address][:locality])
            expect(lines[8]).to start_with("Address 4: ").and(matchers[:address][:county])
            expect(lines[9]).to start_with("Postcode: ").and(matchers[:address][:post_code])
            expect(lines[10]).to start_with("~2.3 Phone number: ").and(matchers[:address_telephone_number])
            expect(lines[11]).to start_with("Mobile number").and(matchers[:mobile_number])
            expect(lines[12]).to start_with("~2.4 How would you prefer us to communicate with you?: ").and(matchers[:contact_preference])
            expect(lines[13]).to start_with("E-mail address: ").and(matchers[:email_address])
            expect(lines[14]).to eql ""
          end
        end

        def has_representative_section?(errors: [], indent: 1, **matcher_overrides) # rubocop:disable Naming/PredicateName
          matchers = representative_matchers.merge(matcher_overrides)
          has_section?(section: :representative, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 7: Your representative"
            expect(lines[1]).to eql ""
            expect(lines[2]).to start_with("~7.1 Representative's name: ").and(matchers[:name])
            expect(lines[3]).to start_with("~7.2 Name of the representative's organisation: ").and(matchers[:organisation_name])
            expect(lines[4]).to start_with("Representative's Address 1: ").and(matchers[:address][:building])
            expect(lines[5]).to start_with("Representative's Address 2: ").and(matchers[:address][:street])
            expect(lines[6]).to start_with("Representative's Address 3: ").and(matchers[:address][:locality])
            expect(lines[7]).to start_with("Representative's Address 4: ").and(matchers[:address][:county])
            expect(lines[8]).to start_with("Representative's Postcode: ").and(matchers[:address][:post_code])
            expect(lines[9]).to start_with("~7.4 Representative's Phone number: ").and(matchers[:address_telephone_number])
            expect(lines[10]).to start_with("~7.5 Representative's Reference: ").and(matchers[:reference])
            expect(lines[11]).to start_with("~7.6 How would they prefer us to communicate with them?:").and(matchers[:contact_preference])
            expect(lines[12]).to start_with("Representative's E-mail address: ").and(matchers[:email_address])
            expect(lines[13]).to eql ""
          end
        end

        def has_footer_section?(errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_section?(section: :footer, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql '**Version: Jadu 1.0'
          end
        end

        def has_correct_contents_for?(response:, respondent:, representative:, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_header_for?(response, errors: errors, indent: indent) &&
            has_intro_for?(response, errors: errors, indent: indent) &&
            has_claimant_for?(response, errors: errors, indent: indent) &&
            has_organisation_for?(respondent, errors: errors, indent: indent) &&
            has_representative_for?(representative, errors: errors, indent: indent) &&
            has_footer_section?(errors: errors, indent: indent)
        end

        def has_correct_contents_from_db_for?(response:, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          respondent = response.respondent.as_json(include: :address).symbolize_keys
          representative = response.representative.try(:as_json, include: :address).try(:symbolize_keys)
          respondent[:address_attributes] = respondent.delete(:address).symbolize_keys
          representative[:address_attributes] = representative.delete(:address).symbolize_keys unless representative.nil?
          response = response.as_json.symbolize_keys
          has_correct_contents_for?(response: response, respondent: respondent, representative: representative, errors: errors, indent: indent)
        end

        def has_header_for?(response, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_header_section? errors: errors, indent: indent,
                              received_at: end_with(Time.zone.now.strftime('%d/%m/%Y')),
                              case_number: end_with(response[:case_number])
        end

        def has_intro_for?(response, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_intro_section? errors: errors, indent: indent,
                             claimants_name: end_with(": #{response[:claimants_name]}"),
                             case_number: end_with(": #{response[:case_number]}"),
                             office_email: end_with(": #{office_email_for(case_number: response[:case_number])}")
        end

        def has_claimant_for?(response, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_claimant_section? errors: errors, indent: indent,
                                name: end_with(": #{response[:claimants_name]}")
        end

        def has_organisation_for?(respondent, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          address = respondent[:address_attributes]
          has_organisation_section? errors: errors, indent: indent,
                                    name: end_with(respondent[:name]),
                                    contact: end_with(respondent[:contact] || ''),
                                    address: {
                                      building: end_with(address[:building]),
                                      street: end_with(address[:street]),
                                      locality: end_with(address[:locality]),
                                      county: end_with(address[:county]),
                                      post_code: end_with(address[:post_code])
                                    },
                                    address_telephone_number: end_with(respondent[:address_telephone_number] || ''),
                                    mobile_number: end_with(respondent[:alt_phone_number] || ''),
                                    contact_preference: end_with(respondent[:contact_preference] || ''),
                                    email_address: end_with(respondent[:email_address] || '')
        end

        def has_representative_for?(rep, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          return has_no_representative?(errors: errors, indent: indent) if rep.nil?
          address = rep[:address_attributes]
          has_representative_section? errors: errors, indent: indent,
                                      name: end_with(rep[:name] || ''),
                                      organisation_name: end_with(rep[:organisation_name] || ''),
                                      address: {
                                        building: end_with(address.try(:[], :building) || ''),
                                        street: end_with(address.try(:[], :street) || ''),
                                        locality: end_with(address.try(:[], :locality) || ''),
                                        county: end_with(address.try(:[], :county) || ''),
                                        post_code: end_with(address.try(:[], :post_code) || '')
                                      },
                                      address_telephone_number: end_with(rep[:address_telephone_number] || ''),
                                      email_address: end_with(rep[:email_address] || ''),
                                      contact_preference: end_with(rep[:contact_preference] || ''),
                                      reference: end_with(rep[:reference] || '')
        end

        def has_no_representative?(errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_representative_section? errors: errors, indent: indent,
                                      name: end_with(': '),
                                      organisation_name: end_with(': '),
                                      address: {
                                        building: end_with(': '),
                                        street: end_with(': '),
                                        locality: end_with(': '),
                                        county: end_with(': '),
                                        post_code: end_with(': ')
                                      },
                                      address_telephone_number: end_with(': '),
                                      email_address: end_with(': '),
                                      contact_preference: end_with(': '),
                                      reference: end_with(': ')
        end

        def section_range(match_start:, match_end:, expect_trailing_blank_line: true)
          start_idx, end_idx = section_start_end(match_start: match_start, match_end: match_end)
          return nil if start_idx.nil? || end_idx.nil?
          return nil if expect_trailing_blank_line && contents[start_idx + end_idx + 1] != ''
          (start_idx..start_idx + end_idx + 1)
        end

        def section_start_end(match_start:, match_end:)
          start_idx = match_start.is_a?(String) ? contents.index(match_start) : contents.index { |l| l =~ match_start }
          return [] if start_idx.nil?
          my_contents = contents[start_idx..-1]
          end_idx = match_end.is_a?(String) ? my_contents.index(match_end) : my_contents.index { |l| l =~ match_end }
          return [] if end_idx.nil?
          [start_idx, end_idx]
        end

        def header_section
          section_range match_start: 'ET3 - Response to an Employment Tribunal claim',
                        match_end: 'FormVersion: 2'
        end

        def intro_section
          section_range match_start: '## Intro: ',
                        match_end: /\A\*\*Tribunal office: /
        end

        def claimant_section
          section_range match_start: /\A## Section 1: Claimant's name/,
                        match_end: /\A~1.1 Claimant's name:/
        end

        def organisation_section
          section_range match_start: "## Section 2: Your organisation's details",
                        match_end: /\AE-mail address: /
        end

        def representative_section
          section_range match_start: "## Section 7: Your representative",
                        match_end: /\ARepresentative's E-mail address: /
        end

        def footer_section
          section_range match_start: '**Version: Jadu 1.0',
                        match_end: '**Version: Jadu 1.0',
                        expect_trailing_blank_line: false
        end

        private

        def claimant_matchers
          @claimant_matchers ||= {
            name: be_a(String)
          }
        end

        def organisation_matchers
          @organisation_matchers ||= {
            name: be_a(String),
            contact: be_a(String),
            address: {
              building: be_a(String),
              street: be_a(String),
              locality: be_a(String),
              county: be_a(String),
              post_code: be_a(String)
            },
            address_telephone_number: be_a(String),
            mobile_number: be_a(String),
            contact_preference: be_a(String),
            email_address: be_a(String)
          }
        end

        def representative_matchers
          @representative_matchers ||= {
            name: be_a(String),
            organisation_name: be_a(String),
            address: {
              building: be_a(String),
              street: be_a(String),
              locality: be_a(String),
              county: be_a(String),
              post_code: be_a(String)
            },
            address_telephone_number: be_a(String),
            mobile_number: be_a(String),
            contact_preference: be_a(String),
            email_address: be_a(String),
            representative_type: be_a(String),
            reference: be_a(String)
          }
        end

        def header_matchers
          @header_matchers ||= {
            received_at: be_a(String),
            case_number: be_a(String)
          }
        end

        def intro_matchers
          @intro_matchers ||= {
            claimants_name: be_a(String),
            case_number: be_a(String),
            office_email: be_a(String)
          }
        end

        def office_email_for(case_number:)
          office_for(case_number: case_number).email
        end

        attr_accessor :contents
      end
    end
  end
end
