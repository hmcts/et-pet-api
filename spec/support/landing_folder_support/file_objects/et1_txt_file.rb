module EtApi
  module Test
    module FileObjects
      class Et1TxtFile < Base # rubocop:disable Metrics/ClassLength
        include RSpec::Matchers

        def initialize(*)
          super
          self.contents = tempfile.readlines.map { |l| l.gsub(/\n\z/, '') }
        end

        def has_correct_file_structure?(errors: []) # rubocop:disable Naming/PredicateName
          has_header_section?(errors: errors)
          has_claimant_section?(errors: errors)
          has_respondents_section?(errors: errors)
          has_representative_section?(errors: errors)
          has_multiple_cases_section?(errors: errors)
          has_additional_respondents_section?(errors: errors)
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

        def has_header_section?(errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_section?(section: :header, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql 'ET1 - Online Application to an Employment Tribunal'
            expect(lines[1]).to eql ''
            expect(lines[2]).to eql 'For Office Use'
            expect(lines[3]).to eql ""
            expect(lines[4]).to start_with "Received at ET: "
            expect(lines[5]).to eql "Case Number:"
            expect(lines[6]).to eql "Code:"
            expect(lines[7]).to eql "Initials:"
            expect(lines[8]).to eql ""
            expect(lines[9]).to start_with "Online Submission Reference: "
            expect(lines[10]).to eql ""
            expect(lines[11]).to eql "FormVersion: 2"
            expect(lines[12]).to eql ""
          end
        end

        def has_claimant_section?(errors: [], indent: 1, **matcher_overrides) # rubocop:disable Naming/PredicateName
          matchers = claimant_matchers.merge(matcher_overrides)
          has_section?(section: :claimant, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to start_with("~1.1 Title: ").and(matchers[:title])
            expect(lines[1]).to eql "Title (other):"
            expect(lines[2]).to start_with("~1.2 First Names: ").and(matchers[:first_name])
            expect(lines[3]).to start_with("~1.3 Surname: ").and(matchers[:last_name])
            expect(lines[4]).to start_with("~1.4 Date of Birth: ").and(matchers[:date_of_birth])
            expect(lines[5]).to start_with("You are: ").and(matchers[:gender])
            expect(lines[6]).to eql "~1.5 Address:"
            expect(lines[7]).to start_with("Address 1: ").and(matchers[:address][:building])
            expect(lines[8]).to start_with("Address 2: ").and(matchers[:address][:street])
            expect(lines[9]).to start_with("Address 3: ").and(matchers[:address][:locality])
            expect(lines[10]).to start_with("Address 4: ").and(matchers[:address][:county])
            expect(lines[11]).to start_with("Postcode: ").and(matchers[:address][:post_code])
            expect(lines[12]).to start_with("~1.6 Phone number: ").and(matchers[:address_telephone_number])
            expect(lines[13]).to start_with("Mobile number: ").and(matchers[:mobile_number])
            expect(lines[14]).to start_with("~1.7 How would you prefer us to communicate with you?: ").and(matchers[:contact_preference])
            expect(lines[15]).to start_with("E-mail address: ").and(matchers[:email_address])
            expect(lines[16]).to eql ""
          end
        end

        def has_respondents_section?(errors: [], indent: 1, **matcher_overrides) # rubocop:disable Naming/PredicateName
          matchers = respondent_matchers.merge(matcher_overrides)
          has_section?(section: :respondents, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 2: Respondent's details"
            expect(lines[1]).to eql ""
            expect(lines[2]).to eql "~2.1 Give the name of your employer or the organisation or person you are complaining about (the respondent):"
            expect(lines[3]).to start_with("Respondent name: ").and(matchers[:name])
            expect(lines[4]).to eql "~2.2 Address:"
            expect(lines[5]).to start_with("Respondent Address 1: ").and(matchers[:address][:building])
            expect(lines[6]).to start_with("Respondent Address 2: ").and(matchers[:address][:street])
            expect(lines[7]).to start_with("Respondent Address 3: ").and(matchers[:address][:locality])
            expect(lines[8]).to start_with("Respondent Address 4: ").and(matchers[:address][:county])
            expect(lines[9]).to start_with("Respondent Postcode: ").and(matchers[:address][:post_code])
            expect(lines[10]).to start_with("Respondent Phone: ").and(matchers[:address_telephone_number])
            expect(lines[11]).to eql "~2.3 If you worked at an address different from the one you have given at 2.2, please give the full address:"
            expect(lines[12]).to start_with("Alternative Respondent Address1: ").and(matchers[:work_address][:building])
            expect(lines[13]).to start_with("Alternative Respondent Address2: ").and(matchers[:work_address][:street])
            expect(lines[14]).to start_with("Alternative Respondent Address3: ").and(matchers[:work_address][:locality])
            expect(lines[15]).to start_with("Alternative Respondent Address4: ").and(matchers[:work_address][:county])
            expect(lines[16]).to start_with("Alternative Postcode: ").and(matchers[:work_address][:post_code])
            expect(lines[17]).to start_with("Alternative Phone: ").and(matchers[:work_address_telephone_number])
            expect(lines[18]).to eql ""
          end
        end

        def has_representative_section?(errors: [], indent: 1, **matcher_overrides) # rubocop:disable Naming/PredicateName
          matchers = representative_matchers.merge(matcher_overrides)
          has_section?(section: :representative, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 8: Your representative"
            expect(lines[1]).to eql ""
            expect(lines[2]).to start_with("~8.1 Representative's name: ").and(matchers[:name])
            expect(lines[3]).to start_with("~8.2 Name of the representative's organisation: ").and(matchers[:organisation_name])
            expect(lines[4]).to eql "~8.3 Address:"
            expect(lines[5]).to start_with("Representative's Address 1: ").and(matchers[:address][:building])
            expect(lines[6]).to start_with("Representative's Address 2: ").and(matchers[:address][:street])
            expect(lines[7]).to start_with("Representative's Address 3: ").and(matchers[:address][:locality])
            expect(lines[8]).to start_with("Representative's Address 4: ").and(matchers[:address][:county])
            expect(lines[9]).to start_with("Representative's Postcode: ").and(matchers[:address][:post_code])
            expect(lines[10]).to start_with("~8.4 Representative's Phone number: ").and(matchers[:address_telephone_number])
            expect(lines[11]).to start_with("Representative's Mobile number: ").and(matchers[:mobile_number])
            expect(lines[12]).to start_with("~8.5 Representative's Reference: ").and(matchers[:dx_number])
            expect(lines[13]).to eql "~8.6 How would they prefer us to communicate with them?:"
            expect(lines[14]).to start_with("Representative's E-mail address: ").and(matchers[:email_address])
            expect(lines[15]).to start_with("~8.7 Representative's Occupation: ").and(matchers[:representative_type])
            expect(lines[16]).to eql ""
          end
        end

        def has_multiple_cases_section?(errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_section?(section: :multiple_cases, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 10: Multiple cases"
            expect(lines[1]).to eql ""
            expect(lines[2]).to start_with "~10.2 ET1a Submitted: "
            expect(lines[3]).to eql ""
          end
        end

        def has_additional_respondents_section?(errors: [], indent: 1, **matcher_overrides) # rubocop:disable Naming/PredicateName
          matchers = additional_respondents_matchers.merge(matcher_overrides)
          has_section?(section: :additional_respondents, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 11: Details of Additional Respondents"
            expect(lines[1]).to eql ""
            expect(lines[2]).to start_with("Name of your employer of the organisation you are claiming against1: ").and(matchers[:name].call(0))
            expect(lines[3]).to eql "Address:"
            expect(lines[4]).to start_with("AdditionalAddress1 1: ").and(matchers[:address][:building].call(0))
            expect(lines[5]).to start_with("AdditionalAddress1 2: ").and(matchers[:address][:street].call(0))
            expect(lines[6]).to start_with("AdditionalAddress1 3: ").and(matchers[:address][:locality].call(0))
            expect(lines[7]).to start_with("AdditionalAddress1 4: ").and(matchers[:address][:county].call(0))
            expect(lines[8]).to start_with("AdditionalPostcode1: ").and(matchers[:address][:post_code].call(0))
            expect(lines[9]).to start_with("AdditionalPhoneNumber1: ").and(matchers[:address_telephone_number].call(0))
            expect(lines[10]).to start_with "Name of your employer of the organisation you are claiming against2: "
            expect(lines[11]).to eql "Address:"
            expect(lines[12]).to start_with("AdditionalAddress2 1: ").and(matchers[:address][:building].call(1))
            expect(lines[13]).to start_with("AdditionalAddress2 2: ").and(matchers[:address][:street].call(1))
            expect(lines[14]).to start_with("AdditionalAddress2 3: ").and(matchers[:address][:locality].call(1))
            expect(lines[15]).to start_with("AdditionalAddress2 4: ").and(matchers[:address][:county].call(1))
            expect(lines[16]).to start_with("AdditionalPostcode2: ").and(matchers[:address][:post_code].call(1))
            expect(lines[17]).to start_with("AdditionalPhoneNumber2: ").and(matchers[:address_telephone_number].call(1))
            expect(lines[18]).to start_with("Name of your employer of the organisation you are claiming against3: ")
            expect(lines[19]).to eql "Address:"
            expect(lines[20]).to start_with("AdditionalAddress3 1: ").and(matchers[:address][:building].call(2))
            expect(lines[21]).to start_with("AdditionalAddress3 2: ").and(matchers[:address][:street].call(2))
            expect(lines[22]).to start_with("AdditionalAddress3 3: ").and(matchers[:address][:locality].call(2))
            expect(lines[23]).to start_with("AdditionalAddress3 4: ").and(matchers[:address][:county].call(2))
            expect(lines[24]).to start_with("AdditionalPostcode3: ").and(matchers[:address][:post_code].call(2))
            expect(lines[25]).to start_with("AdditionalPhoneNumber3: ").and(matchers[:address_telephone_number].call(2))
            expect(lines[26]).to eql ""
          end
        end

        def has_claimant_for?(claimant, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          a = claimant[:address]
          has_claimant_section? errors: errors, indent: indent,
                                title: end_with(claimant[:title]),
                                first_name: end_with(claimant[:first_name]),
                                last_name: end_with(claimant[:last_name]),
                                date_of_birth: end_with(claimant[:date_of_birth].strftime('%d/%m/%Y')),
                                gender: end_with(claimant[:gender]),
                                address: {
                                  building: end_with(a[:building]),
                                  street: end_with(a[:street]),
                                  locality: end_with(a[:locality]),
                                  county: end_with(a[:county]),
                                  post_code: end_with(a[:post_code])
                                },
                                address_telephone_number: end_with(claimant[:address_telephone_number]),
                                mobile_number: end_with(claimant[:mobile_number]),
                                contact_preference: end_with(claimant[:contact_preference]),
                                email_address: end_with(claimant[:email_address])
        end

        def has_respondent_for?(respondent, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          address = respondent[:address]
          work_address = respondent[:work_address]
          has_respondents_section? errors: errors, indent: indent,
                                   name: end_with(respondent[:name]),
                                   address: {
                                     building: end_with(address[:building]),
                                     street: end_with(address[:street]),
                                     locality: end_with(address[:locality]),
                                     county: end_with(address[:county]),
                                     post_code: end_with(address[:post_code])
                                   },
                                   work_address: {
                                     building: end_with(work_address[:building]),
                                     street: end_with(work_address[:street]),
                                     locality: end_with(work_address[:locality]),
                                     county: end_with(work_address[:county]),
                                     post_code: end_with(work_address[:post_code])
                                   },
                                   work_address_telephone_number: end_with(respondent[:work_address_telephone_number]),
                                   address_telephone_number: end_with(respondent[:address_telephone_number])
        end

        def has_representative_for?(rep, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          address = rep[:address]
          has_representative_section? errors: errors, indent: indent,
                                      name: end_with(rep[:name]),
                                      organisation_name: end_with(rep[:organisation_name]),
                                      address: {
                                        building: end_with(address[:building]),
                                        street: end_with(address[:street]),
                                        locality: end_with(address[:locality]),
                                        county: end_with(address[:county]),
                                        post_code: end_with(address[:post_code])
                                      },
                                      address_telephone_number: end_with(rep[:address_telephone_number]),
                                      mobile_number: end_with(rep[:mobile_number]),
                                      email_address: end_with(rep[:email_address]),
                                      representative_type: end_with(rep[:representative_type]),
                                      dx_number: end_with(rep[:dx_number])
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
                                      mobile_number: end_with(': '),
                                      email_address: end_with(': '),
                                      representative_type: end_with(': '),
                                      dx_number: end_with(': ')
        end

        def has_additional_respondents_for?(r, errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_additional_respondents_section? errors: errors, indent: indent,
                                              name: ->(idx) { end_with(r[idx]&.dig(:name).to_s) },
                                              address: {
                                                building: ->(idx) { end_with(r[idx]&.dig(:building).to_s) },
                                                street: ->(idx) { end_with(r[idx]&.dig(:street).to_s) },
                                                locality: ->(idx) { end_with(r[idx]&.dig(:locality).to_s) },
                                                county: ->(idx) { end_with(r[idx]&.dig(:county).to_s) },
                                                post_code: ->(idx) { end_with(r[idx]&.dig(:post_code).to_s) },
                                              },
                                              address_telephone_number: ->(idx) { end_with(r[idx]&.dig(:address_telephone_number).to_s) }
        end

        def has_no_additional_respondents?(errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_additional_respondents_section? errors: errors, indent: indent,
                                              name: ->(*) { end_with(': ') },
                                              address: {
                                                building: ->(*) { end_with(': ') },
                                                street: ->(*) { end_with(': ') },
                                                locality: ->(*) { end_with(': ') },
                                                county: ->(*) { end_with(': ') },
                                                post_code: ->(*) { end_with(': ') },
                                              },
                                              address_telephone_number: ->(*) { end_with(': ') }
        end



        def section_range(match_start:, match_end:)
          start_idx = match_start.is_a?(String) ? contents.index(match_start) : contents.index { |l| l =~ match_start }
          return nil if start_idx.nil?
          my_contents = contents[start_idx..-1]
          end_idx = match_end.is_a?(String) ? my_contents.index(match_end) : my_contents.index { |l| l =~ match_end }
          return nil if end_idx.nil?
          return nil if my_contents[end_idx + 1] != ''
          (start_idx..start_idx + end_idx + 1)
        end

        def header_section
          section_range match_start: 'ET1 - Online Application to an Employment Tribunal',
                        match_end: 'FormVersion: 2'
        end

        def claimant_section
          section_range match_start: /\A~1.1 Title:/,
                        match_end: /\AE-mail address: /
        end

        def respondents_section
          section_range match_start: "## Section 2: Respondent's details",
                        match_end: /\AAlternative Phone: /
        end

        def representative_section
          section_range match_start: "## Section 8: Your representative",
                        match_end: /\A~8.7 Representative's Occupation: /
        end

        def multiple_cases_section
          section_range match_start: "## Section 10: Multiple cases",
                        match_end: /\A~10.2 ET1a Submitted: /
        end

        def additional_respondents_section
          section_range match_start: "## Section 11: Details of Additional Respondents",
                        match_end: /\AAdditionalPhoneNumber3:/
        end

        private

        def claimant_matchers
          @claimant_matchers ||= {
            title: be_a(String),
            first_name: be_a(String),
            last_name: be_a(String),
            date_of_birth: be_a(String),
            gender: be_a(String),
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

        def respondent_matchers
          @respondent_matchers ||= {
            name: be_a(String),
            address: {
              building: be_a(String),
              street: be_a(String),
              locality: be_a(String),
              county: be_a(String),
              post_code: be_a(String)
            },
            work_address: {
              building: be_a(String),
              street: be_a(String),
              locality: be_a(String),
              county: be_a(String),
              post_code: be_a(String)
            },
            address_telephone_number: be_a(String),
            work_address_telephone_number: be_a(String)
          }
        end

        def additional_respondents_matchers
          @additional_respondents_matchers ||= {
            name: ->(*) { be_a(String) },
            address: {
              building: ->(*) { be_a(String) },
              street: ->(*) { be_a(String) },
              locality: ->(*) { be_a(String) },
              county: ->(*) { be_a(String) },
              post_code: ->(*) { be_a(String) }
            },
            address_telephone_number: ->(*) { be_a(String) }
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
            email_address: be_a(String),
            representative_type: be_a(String),
            dx_number: be_a(String)
          }
        end

        attr_accessor :contents
      end
    end
  end
end
