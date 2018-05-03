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

        def has_claimant_section?(errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_section?(section: :claimant, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to start_with "~1.1 Title: "
            expect(lines[1]).to eql "Title (other):"
            expect(lines[2]).to start_with "~1.2 First Names: "
            expect(lines[3]).to start_with "~1.3 Surname: "
            expect(lines[4]).to start_with "~1.4 Date of Birth: "
            expect(lines[5]).to start_with "You are: "
            expect(lines[6]).to eql "~1.5 Address:"
            expect(lines[7]).to start_with "Address 1: "
            expect(lines[8]).to start_with "Address 2: "
            expect(lines[9]).to start_with "Address 3: "
            expect(lines[10]).to start_with "Address 4: "
            expect(lines[11]).to start_with "Postcode: "
            expect(lines[12]).to start_with "~1.6 Phone number: "
            expect(lines[13]).to start_with "Mobile number: "
            expect(lines[14]).to start_with "~1.7 How would you prefer us to communicate with you?: "
            expect(lines[15]).to start_with "E-mail address: "
            expect(lines[16]).to eql ""
          end
        end

        def has_respondents_section?(errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_section?(section: :respondents, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 2: Respondent's details"
            expect(lines[1]).to eql ""
            expect(lines[2]).to eql "~2.1 Give the name of your employer or the organisation or person you are complaining about (the respondent):"
            expect(lines[3]).to start_with "Respondent name: "
            expect(lines[4]).to eql "~2.2 Address:"
            expect(lines[5]).to start_with "Respondent Address 1: "
            expect(lines[6]).to start_with "Respondent Address 2: "
            expect(lines[7]).to start_with "Respondent Address 3: "
            expect(lines[8]).to start_with "Respondent Address 4: "
            expect(lines[9]).to start_with "Respondent Postcode: "
            expect(lines[10]).to start_with "Respondent Phone: "
            expect(lines[11]).to eql "~2.3 If you worked at an address different from the one you have given at 2.2, please give the full address:"
            expect(lines[12]).to start_with "Alternative Respondent Address1: "
            expect(lines[13]).to start_with "Alternative Respondent Address2: "
            expect(lines[14]).to start_with "Alternative Respondent Address3: "
            expect(lines[15]).to start_with "Alternative Respondent Address4: "
            expect(lines[16]).to start_with "Alternative Postcode: "
            expect(lines[17]).to start_with "Alternative Phone: "
            expect(lines[18]).to eql ""
          end
        end

        def has_representative_section?(errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_section?(section: :representative, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 8: Your representative"
            expect(lines[1]).to eql ""
            expect(lines[2]).to start_with "~8.1 Representative's name: "
            expect(lines[3]).to start_with "~8.2 Name of the representative's organisation: "
            expect(lines[4]).to eql "~8.3 Address:"
            expect(lines[5]).to start_with "Representative's Address 1: "
            expect(lines[6]).to start_with "Representative's Address 2: "
            expect(lines[7]).to start_with "Representative's Address 3: "
            expect(lines[8]).to start_with "Representative's Address 4: "
            expect(lines[9]).to start_with "Representative's Postcode: "
            expect(lines[10]).to start_with "~8.4 Representative's Phone number: "
            expect(lines[11]).to start_with "Representative's Mobile number: "
            expect(lines[12]).to start_with "~8.5 Representative's Reference: "
            expect(lines[13]).to eql "~8.6 How would they prefer us to communicate with them?:"
            expect(lines[14]).to start_with "Representative's E-mail address: "
            expect(lines[15]).to start_with "~8.7 Representative's Occupation: "
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

        def has_additional_respondents_section?(errors: [], indent: 1) # rubocop:disable Naming/PredicateName
          has_section?(section: :additional_respondents, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "## Section 11: Details of Additional Respondents"
            expect(lines[1]).to eql ""
            expect(lines[2]).to start_with "Name of your employer of the organisation you are claiming against1: "
            expect(lines[3]).to eql "Address:"
            expect(lines[4]).to start_with "AdditionalAddress1 1: "
            expect(lines[5]).to start_with "AdditionalAddress1 2: "
            expect(lines[6]).to start_with "AdditionalAddress1 3: "
            expect(lines[7]).to start_with "AdditionalAddress1 4: "
            expect(lines[8]).to start_with "AdditionalPostcode1: "
            expect(lines[9]).to start_with "AdditionalPhoneNumber1: "
            expect(lines[10]).to start_with "Name of your employer of the organisation you are claiming against2: "
            expect(lines[11]).to eql "Address:"
            expect(lines[12]).to start_with "AdditionalAddress2 1: "
            expect(lines[13]).to start_with "AdditionalAddress2 2: "
            expect(lines[14]).to start_with "AdditionalAddress2 3: "
            expect(lines[15]).to start_with "AdditionalAddress2 4: "
            expect(lines[16]).to start_with "AdditionalPostcode2: "
            expect(lines[17]).to start_with "AdditionalPhoneNumber2: "
            expect(lines[18]).to start_with "Name of your employer of the organisation you are claiming against3: "
            expect(lines[19]).to eql "Address:"
            expect(lines[20]).to start_with "AdditionalAddress3 1: "
            expect(lines[21]).to start_with "AdditionalAddress3 2: "
            expect(lines[22]).to start_with "AdditionalAddress3 3: "
            expect(lines[23]).to start_with "AdditionalAddress3 4: "
            expect(lines[24]).to start_with "AdditionalPostcode3: "
            expect(lines[25]).to start_with "AdditionalPhoneNumber3: "
            expect(lines[26]).to eql ""
          end
        end

        def has_claimant_for?(claimant, errors: [], indent: 1)
          has_section?(section: :claimant, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql "~1.1 Title: #{claimant[:title]}"
            expect(lines[1]).to eql "Title (other):"
            expect(lines[2]).to start_with "~1.2 First Names: #{claimant[:first_name]}"
            expect(lines[3]).to start_with "~1.3 Surname: #{claimant[:last_name]}"
            expect(lines[4]).to start_with "~1.4 Date of Birth: #{claimant[:date_of_birth].strftime('%d/%m/%Y')}"
            expect(lines[5]).to start_with "You are: #{claimant[:gender]}"
            expect(lines[6]).to eql "~1.5 Address:"
            claimant[:address].tap do |a|
              expect(lines[7]).to start_with "Address 1: #{a[:building]}"
              expect(lines[8]).to start_with "Address 2: #{a[:street]}"
              expect(lines[9]).to start_with "Address 3: #{a[:locality]}"
              expect(lines[10]).to start_with "Address 4: #{a[:county]}"
              expect(lines[11]).to start_with "Postcode: #{a[:post_code]}"

            end
            expect(lines[12]).to start_with "~1.6 Phone number: #{claimant[:address_telephone_number]}"
            expect(lines[13]).to start_with "Mobile number: #{claimant[:mobile_number]}"
            expect(lines[14]).to start_with "~1.7 How would you prefer us to communicate with you?: #{claimant[:contact_preference]}"
            expect(lines[15]).to start_with "E-mail address: #{claimant[:email_address]}"
            expect(lines[16]).to eql ""
          end
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

        attr_accessor :contents
      end
    end
  end
end
