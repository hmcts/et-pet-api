require_relative 'base'
module EtApi
  module Test
    module FileObjects
      class Et1aTxtFile < Base
        include RSpec::Matchers
        include Enumerable

        def each
          loop do
            break unless find_claimant_start
            break unless find_claimant_end

            yield captured
          end
        end

        def initialize(*)
          super
          self.contents = tempfile.readlines("\r\n")[0..15].map { |l| l.gsub(/\r\n\z/, '') }
          cloned_tempfile = tempfile.clone
          cloned_tempfile.rewind
        end

        def has_correct_encoding?(errors: [], indent: 1)
          expect(tempfile.path).to have_file_encoding('unknown-8bit').or have_file_encoding('us-ascii')
          true
        rescue RSpec::Expectations::ExpectationNotMetError => e
          errors.concat(e.message.lines.map { |l| "#{'  ' * indent}#{l.gsub(/\n\z/, '')}" })
          false
        end

        def has_correct_file_structure?(errors: [])
          has_header_section?(errors: errors)
          has_claimants_sections?(errors: errors)
          errors.empty?
        end

        def has_section?(section:, errors: [], indent: 1)
          section_range = send(:"#{section}_section")
          if section_range.nil?
            errors << "Could not find a '#{section.to_s.humanize}' section"
            return false
          end
          lines = contents.slice(section_range)
          aggregate_failures "Match content against schema for '#{section.to_s.humanize}'" do
            yield(lines)
          end
          true
        rescue RSpec::Expectations::ExpectationNotMetError => e
          errors << "Missing or invalid '#{section.to_s.humanize}' section"
          errors.concat(e.message.lines.map { |l| "#{'  ' * indent}#{l.gsub(/\n\z/, '')}" })
          false
        end

        def has_header_section?(errors: [], indent: 1, **matcher_overrides)
          matchers = header_matchers.merge(matcher_overrides)
          has_section?(section: :header, errors: errors, indent: indent) do |lines|
            expect(lines[0]).to eql 'ET1a - Online Application to an Employment Tribunal'
            expect(lines[1]).to eql ''
            expect(lines[2]).to eql 'For Office Use'
            expect(lines[3]).to eql ""
            expect(lines[4]).to start_with("Received at ET: ").and(matchers[:date_of_receipt])
            expect(lines[5]).to eql "Case Number:"
            expect(lines[6]).to eql "Code:"
            expect(lines[7]).to eql "Initials:"
            expect(lines[8]).to eql ""
            expect(lines[9]).to start_with("Online Submission Reference: ").and(matchers[:reference])
            expect(lines[10]).to eql ""
            expect(lines[11]).to eql "FormVersion: 2"
            expect(lines[12]).to eql ""
            expect(lines[13]).to start_with("The following claimants are represented by  (if applicable) and the relevant required information for all the additional claimants is the same as stated in the main claim of ").and(matchers[:claim_parties])
            expect(lines[14]).to eql ''
            expect(lines[15]).to eql ''
          end
        end

        def has_claimants_sections?(errors: [], indent: 1, **matcher_overrides)
          matchers = claimant_matchers.merge(matcher_overrides)
          idx = 0
          each do |lines|
            aggregate_failures "validating claimant #{idx}" do
              expect(lines[0]).to start_with('## Section et1a: claim')
              expect(lines[1]).to start_with('')
              expect(lines[2]).to start_with('~1.1 Title: ').and(matchers[:title].call(idx))
              expect(lines[3]).to start_with('~1.2 First Names: ').and(matchers[:first_name].call(idx))
              expect(lines[4]).to start_with('~1.3 Surname: ').and(matchers[:last_name].call(idx))
              expect(lines[5]).to start_with('~1.4 Date of Birth: ').and(matchers[:date_of_birth].call(idx))
              expect(lines[6]).to start_with('~1.5 Address:')
              expect(lines[7]).to start_with('Address 1: ').and(matchers[:address][:building].call(idx))
              expect(lines[8]).to start_with('Address 2: ').and(matchers[:address][:street].call(idx))
              expect(lines[9]).to start_with('Address 3: ').and(matchers[:address][:locality].call(idx))
              expect(lines[10]).to start_with('Address 4: ').and(matchers[:address][:county].call(idx))
              expect(lines[11]).to start_with('Postcode: ').and(matchers[:address][:post_code].call(idx))
              expect(lines[12]).to start_with('')
            end
            idx += 1
          end
          idx
        rescue RSpec::Expectations::ExpectationNotMetError => e
          errors << "Missing or invalid claimants section - checking index #{idx}"
          errors.concat(e.message.lines.map { |l| "#{'  ' * indent}#{l.gsub(/\n\z/, '')}" })
          idx
        end

        def has_header_for?(claim, primary_claimant:, primary_respondent:, reference:, errors: [], indent: 1)
          claimant = primary_claimant
          has_header_section? errors: errors, indent: indent,
                              reference: end_with(reference),
                              date_of_receipt: end_with(claim[:date_of_receipt].strftime('%d/%m/%Y')),
                              claim_parties: end_with("#{claimant[:first_name]} #{claimant[:last_name]} v #{primary_respondent[:name]}")
        end

        def has_claimants_for?(claimants, errors: [], indent: 1)
          count = has_claimants_sections? errors: errors, indent: indent,
                                          title: ->(idx) { end_with(claimants[idx][:title]) },
                                          first_name: ->(idx) { end_with(claimants[idx][:first_name]) },
                                          last_name: ->(idx) { end_with(claimants[idx][:last_name]) },
                                          date_of_birth: ->(idx) { end_with(claimants[idx][:date_of_birth].strftime('%d/%m/%Y')) },
                                          address: {
                                            building: ->(idx) { end_with(claimants[idx][:address][:building]) },
                                            street: ->(idx) { end_with(claimants[idx][:address][:street]) },
                                            locality: ->(idx) { end_with(claimants[idx][:address][:locality]) },
                                            county: ->(idx) { end_with(claimants[idx][:address][:county]) },
                                            post_code: ->(idx) { end_with(claimants[idx][:address][:post_code]) }
                                          }
          if count < claimants.length
            errors << "Matched first #{count - 1} claimants - but expected #{claimants.length}"
            return false
          end
          true
        end

        def section_range(match_start:, match_end:, additional_lines_after_end: 1)
          start_idx = match_start.is_a?(String) ? contents.index(match_start) : contents.index { |l| l =~ match_start }
          return nil if start_idx.nil?

          my_contents = contents[start_idx..]
          end_idx = match_end.is_a?(String) ? my_contents.index(match_end) : my_contents.index { |l| l =~ match_end }
          return nil if end_idx.nil?
          return nil if my_contents[end_idx + 1] != ''

          (start_idx..(start_idx + end_idx + additional_lines_after_end))
        end

        def header_section
          section_range match_start: 'ET1a - Online Application to an Employment Tribunal',
                        match_end: /\AThe following claimants are represented by/,
                        additional_lines_after_end: 2
        end

        private

        def header_matchers
          @header_matchers ||= {
            reference: be_a(String),
            date_of_receipt: be_a(String),
            claim_parties: be_a(String)
          }
        end

        def claimant_matchers
          @claimant_matchers ||= {
            title: ->(*) { be_a(String) },
            first_name: ->(*) { be_a(String) },
            last_name: ->(*) { be_a(String) },
            date_of_birth: ->(*) { be_a(String) },
            address: {
              building: ->(*) { be_a(String) },
              street: ->(*) { be_a(String) },
              locality: ->(*) { be_a(String) },
              county: ->(*) { be_a(String) },
              post_code: ->(*) { be_a(String) }
            }
          }
        end

        def find_claimant_start
          self.captured = []
          loop do
            line = tempfile.readline("\r\n")
            if line.start_with?('## Section et1a: claim')
              captured << line.gsub(/\r\n\z/, '')
              break
            end
          end
          captured.present?
        rescue EOFError
          false
        end

        def find_claimant_end
          loop do
            line = tempfile.readline("\r\n")
            captured << line.gsub(/\r\n\z/, '')
            next unless line.start_with?('Postcode: ')

            captured << tempfile.readline.gsub(/\r\n\z/, '')
            captured << tempfile.readline.gsub(/\r\n\z/, '')
            captured << tempfile.readline.gsub(/\r\n\z/, '')
            break
          end
          true
        rescue EOFError
          false
        end

        attr_accessor :contents, :captured
      end
    end
  end
end
