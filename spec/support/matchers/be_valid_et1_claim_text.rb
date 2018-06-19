module EtApi
  module Test
    # A matcher to prove that the provided text matches exactly what it should
    # look like according to the examples provided to the project.
    # Note that this is deliberately strict - even to the popint of expecting
    # blank lines etc..
    # This is because it is unknown how the receiving system would react to any differences from the example
    class BeValidEt1ClaimTextMatcher # rubocop:disable Metrics/ClassLength
      include ::RSpec::Matchers
      def initialize(multiple_claimants: false, representative: true)
        self.multiple_claimants = multiple_claimants
        self.representative = representative
      end

      def matches?(actual)
        actual_lines = actual.lines("\r\n").map { |l| l.gsub(/\r\n\z/, '') }
        aggregate_failures 'Match content against a standard ET1 Claim Text File' do
          expect(actual_lines[0]).to eql 'ET1 - Online Application to an Employment Tribunal'
          expect(actual_lines[1]).to eql ''
          expect(actual_lines[2]).to eql 'For Office Use'
          expect(actual_lines[3]).to eql ""
          expect(actual_lines[4]).to eql "Received at ET: 29/03/2018"
          expect(actual_lines[5]).to eql "Case Number:"
          expect(actual_lines[6]).to eql "Code:"
          expect(actual_lines[7]).to eql "Initials:"
          expect(actual_lines[8]).to eql ""
          expect(actual_lines[9]).to eql "Online Submission Reference: 222000000300"
          expect(actual_lines[10]).to eql ""
          expect(actual_lines[11]).to eql "FormVersion: 2"
          expect(actual_lines[12]).to eql ""
          expect(actual_lines[13]).to eql "~1.1 Title: Mr"
          expect(actual_lines[14]).to eql "Title (other):"
          expect(actual_lines[15]).to eql "~1.2 First Names: First"
          expect(actual_lines[16]).to eql "~1.3 Surname: Last"
          expect(actual_lines[17]).to eql "~1.4 Date of Birth: 21/11/1982"
          expect(actual_lines[18]).to eql "You are: Male"
          expect(actual_lines[19]).to eql "~1.5 Address:"
          expect(actual_lines[20]).to eql "Address 1: 102"
          expect(actual_lines[21]).to eql "Address 2: Petty France"
          expect(actual_lines[22]).to eql "Address 3: London"
          expect(actual_lines[23]).to eql "Address 4: Greater London"
          expect(actual_lines[24]).to eql "Postcode: SW1H 9AJ"
          expect(actual_lines[25]).to eql "~1.6 Phone number: 01234 567890"
          expect(actual_lines[26]).to eql "Mobile number: 01234 098765"
          expect(actual_lines[27]).to eql "~1.7 How would you prefer us to communicate with you?: Email"
          expect(actual_lines[28]).to eql "E-mail address: test@digital.justice.gov.uk"
          expect(actual_lines[29]).to eql ""
          expect(actual_lines[30]).to eql "## Section 2: Respondent's details"
          expect(actual_lines[31]).to eql ""
          expect(actual_lines[32]).to eql "~2.1 Give the name of your employer or the organisation or person you are complaining about (the respondent):"
          expect(actual_lines[33]).to eql "Respondent name: Respondent Name"
          expect(actual_lines[34]).to eql "~2.2 Address:"
          expect(actual_lines[35]).to eql "Respondent Address 1: 108"
          expect(actual_lines[36]).to eql "Respondent Address 2: Regent Street"
          expect(actual_lines[37]).to eql "Respondent Address 3: London"
          expect(actual_lines[38]).to eql "Respondent Address 4: Greater London"
          expect(actual_lines[39]).to eql "Respondent Postcode: SW1H 9QR"
          expect(actual_lines[40]).to eql "Respondent Phone: 02222 321654"
          expect(actual_lines[41]).to eql "~2.3 If you worked at an address different from the one you have given at 2.2, please give the full address:"
          expect(actual_lines[42]).to eql "Alternative Respondent Address1: 110"
          expect(actual_lines[43]).to eql "Alternative Respondent Address2: Piccadily Circus"
          expect(actual_lines[44]).to eql "Alternative Respondent Address3: London"
          expect(actual_lines[45]).to eql "Alternative Respondent Address4: Greater London"
          expect(actual_lines[46]).to eql "Alternative Postcode: SW1H 9ST"
          expect(actual_lines[47]).to eql "Alternative Phone: 03333 423554"
          expect(actual_lines[48]).to eql ""
          expect(actual_lines[49]).to eql "## Section 8: Your representative"
          expect(actual_lines[50]).to eql ""
          if representative
            expect(actual_lines[51]).to eql "~8.1 Representative's name: Solicitor Name"
            expect(actual_lines[52]).to eql "~8.2 Name of the representative's organisation: Solicitors Are Us Fake Company"
            expect(actual_lines[53]).to eql "~8.3 Address:"
            expect(actual_lines[54]).to eql "Representative's Address 1: 106"
            expect(actual_lines[55]).to eql "Representative's Address 2: Mayfair"
            expect(actual_lines[56]).to eql "Representative's Address 3: London"
            expect(actual_lines[57]).to eql "Representative's Address 4: Greater London"
            expect(actual_lines[58]).to eql "Representative's Postcode: SW1H 9PP"
            expect(actual_lines[59]).to eql "~8.4 Representative's Phone number: 01111 123456"
            expect(actual_lines[60]).to eql "Representative's Mobile number: 02222 654321"
            expect(actual_lines[61]).to eql "~8.5 Representative's Reference: dx1234567890"
            expect(actual_lines[62]).to eql "~8.6 How would they prefer us to communicate with them?:"
            expect(actual_lines[63]).to eql "Representative's E-mail address: solicitor.test@digital.justice.gov.uk"
            expect(actual_lines[64]).to eql "~8.7 Representative's Occupation: Solicitor"
          else
            expect(actual_lines[51]).to eql "~8.1 Representative's name: "
            expect(actual_lines[52]).to eql "~8.2 Name of the representative's organisation: "
            expect(actual_lines[53]).to eql "~8.3 Address:"
            expect(actual_lines[54]).to eql "Representative's Address 1: "
            expect(actual_lines[55]).to eql "Representative's Address 2: "
            expect(actual_lines[56]).to eql "Representative's Address 3: "
            expect(actual_lines[57]).to eql "Representative's Address 4: "
            expect(actual_lines[58]).to eql "Representative's Postcode: "
            expect(actual_lines[59]).to eql "~8.4 Representative's Phone number: "
            expect(actual_lines[60]).to eql "Representative's Mobile number: "
            expect(actual_lines[61]).to eql "~8.5 Representative's Reference: "
            expect(actual_lines[62]).to eql "~8.6 How would they prefer us to communicate with them?:"
            expect(actual_lines[63]).to eql "Representative's E-mail address: "
            expect(actual_lines[64]).to eql "~8.7 Representative's Occupation: "

          end
          expect(actual_lines[65]).to eql ""
          expect(actual_lines[66]).to eql "## Section 10: Multiple cases"
          expect(actual_lines[67]).to eql ""
          if multiple_claimants
            expect(actual_lines[68]).to eql "~10.2 ET1a Submitted: Yes"
          else
            expect(actual_lines[68]).to eql "~10.2 ET1a Submitted: "
          end
          expect(actual_lines[69]).to eql ""
          expect(actual_lines[70]).to eql "## Section 11: Details of Additional Respondents"
          expect(actual_lines[71]).to eql ""
          expect(actual_lines[72]).to eql "Name of your employer of the organisation you are claiming against1: "
          expect(actual_lines[73]).to eql "Address:"
          expect(actual_lines[74]).to eql "AdditionalAddress1 1: "
          expect(actual_lines[75]).to eql "AdditionalAddress1 2: "
          expect(actual_lines[76]).to eql "AdditionalAddress1 3: "
          expect(actual_lines[77]).to eql "AdditionalAddress1 4: "
          expect(actual_lines[78]).to eql "AdditionalPostcode1: "
          expect(actual_lines[79]).to eql "AdditionalPhoneNumber1: "
          expect(actual_lines[80]).to eql "Name of your employer of the organisation you are claiming against2: "
          expect(actual_lines[81]).to eql "Address:"
          expect(actual_lines[82]).to eql "AdditionalAddress2 1: "
          expect(actual_lines[83]).to eql "AdditionalAddress2 2: "
          expect(actual_lines[84]).to eql "AdditionalAddress2 3: "
          expect(actual_lines[85]).to eql "AdditionalAddress2 4: "
          expect(actual_lines[86]).to eql "AdditionalPostcode2: "
          expect(actual_lines[87]).to eql "AdditionalPhoneNumber2: "
          expect(actual_lines[88]).to eql "Name of your employer of the organisation you are claiming against3: "
          expect(actual_lines[89]).to eql "Address:"
          expect(actual_lines[90]).to eql "AdditionalAddress3 1: "
          expect(actual_lines[91]).to eql "AdditionalAddress3 2: "
          expect(actual_lines[92]).to eql "AdditionalAddress3 3: "
          expect(actual_lines[93]).to eql "AdditionalAddress3 4: "
          expect(actual_lines[94]).to eql "AdditionalPostcode3: "
          expect(actual_lines[95]).to eql "AdditionalPhoneNumber3: "
        end
        true
      end

      private

      attr_accessor :multiple_claimants, :representative
    end
  end
end

def be_valid_et1_claim_text(*args)
  ::EtApi::Test::BeValidEt1ClaimTextMatcher.new(*args)
end
