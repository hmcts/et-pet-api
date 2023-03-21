module EtApi
  module Test
    # A matcher to prove that the provided text matches exactly what it should
    # look like according to the examples provided to the project.
    # Note that this is deliberately strict - even to the popint of expecting
    # blank lines etc..
    # This is because it is unknown how the receiving system would react to any differences from the example
    class BeValidEt1aClaimTextMatcher # rubocop:disable Metrics/ClassLength
      include ::RSpec::Matchers

      def initialize(claim:)
        @claim = claim
      end

      def matches?(actual)
        respondent = @claim.primary_respondent
        actual_lines = actual.lines("\r\n").map { |l| l.gsub(/\r\n\z/, '') }
        aggregate_failures 'Match content against a standard ET1 Claim Text File' do
          expect(actual_lines[0]).to eql 'ET1a - Online Application to an Employment Tribunal'
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
          expect(actual_lines[13]).to eql "The following claimants are represented by  (if applicable) and the relevant required information for all the additional claimants is the same as stated in the main claim of First Last v #{respondent.name}"
          expect(actual_lines[14]).to eql ''
          expect(actual_lines[15]).to eql ''
          expect(actual_lines[16]).to eql '## Section et1a: claim'
          expect(actual_lines[17]).to eql ''
          expect(actual_lines[18]).to eql '~1.1 Title: Mrs'
          expect(actual_lines[19]).to eql '~1.2 First Names: Tamara'
          expect(actual_lines[20]).to eql '~1.3 Surname: Swift'
          expect(actual_lines[21]).to eql '~1.4 Date of Birth: 06/07/1957'
          expect(actual_lines[22]).to eql '~1.5 Address:'
          expect(actual_lines[23]).to eql 'Address 1: 71088'
          expect(actual_lines[24]).to eql 'Address 2: Nova Loaf'
          expect(actual_lines[25]).to eql 'Address 3: Keelingborough'
          expect(actual_lines[26]).to eql 'Address 4: Hawaii'
          expect(actual_lines[27]).to eql 'Postcode: YY9A 2LA'
          expect(actual_lines[28]).to eql ''
          expect(actual_lines[29]).to eql ''
          expect(actual_lines[30]).to eql ''
          expect(actual_lines[31]).to eql '## Section et1a: claim'
          expect(actual_lines[32]).to eql ''
          expect(actual_lines[33]).to eql '~1.1 Title: Mr'
          expect(actual_lines[34]).to eql '~1.2 First Names: diana'
          expect(actual_lines[35]).to eql '~1.3 Surname: flatley'
          expect(actual_lines[36]).to eql '~1.4 Date of Birth: 24/09/1986'
          expect(actual_lines[37]).to eql '~1.5 Address:'
          expect(actual_lines[38]).to eql 'Address 1: 66262'
          expect(actual_lines[39]).to eql 'Address 2: feeney station'
          expect(actual_lines[40]).to eql 'Address 3: west jewelstad'
          expect(actual_lines[41]).to eql 'Address 4: montana'
          expect(actual_lines[42]).to eql 'Postcode: r8p 0jb'
          expect(actual_lines[43]).to eql ''
          expect(actual_lines[44]).to eql ''
          expect(actual_lines[45]).to eql ''
          expect(actual_lines[46]).to eql '## Section et1a: claim'
          expect(actual_lines[47]).to eql ''
          expect(actual_lines[48]).to eql '~1.1 Title: Ms'
          expect(actual_lines[49]).to eql '~1.2 First Names: mariana'
          expect(actual_lines[50]).to eql '~1.3 Surname: mccullough'
          expect(actual_lines[51]).to eql '~1.4 Date of Birth: 10/08/1992'
          expect(actual_lines[52]).to eql '~1.5 Address:'
          expect(actual_lines[53]).to eql 'Address 1: 819'
          expect(actual_lines[54]).to eql 'Address 2: mitchell glen'
          expect(actual_lines[55]).to eql 'Address 3: east oliverton'
          expect(actual_lines[56]).to eql 'Address 4: south carolina'
          expect(actual_lines[57]).to eql 'Postcode: uh2 4na'
          expect(actual_lines[58]).to eql ''
          expect(actual_lines[59]).to eql ''
          expect(actual_lines[60]).to eql ''
          expect(actual_lines[61]).to eql '## Section et1a: claim'
          expect(actual_lines[62]).to eql ''
          expect(actual_lines[63]).to eql '~1.1 Title: Mr'
          expect(actual_lines[64]).to eql '~1.2 First Names: eden'
          expect(actual_lines[65]).to eql '~1.3 Surname: upton'
          expect(actual_lines[66]).to eql '~1.4 Date of Birth: 09/01/1965'
          expect(actual_lines[67]).to eql '~1.5 Address:'
          expect(actual_lines[68]).to eql 'Address 1: 272'
          expect(actual_lines[69]).to eql 'Address 2: hoeger lodge'
          expect(actual_lines[70]).to eql 'Address 3: west roxane'
          expect(actual_lines[71]).to eql 'Address 4: new mexico'
          expect(actual_lines[72]).to eql 'Postcode: pd3p 8ns'
          expect(actual_lines[73]).to eql ''
          expect(actual_lines[74]).to eql ''
          expect(actual_lines[75]).to eql ''
          expect(actual_lines[76]).to eql '## Section et1a: claim'
          expect(actual_lines[77]).to eql ''
          expect(actual_lines[78]).to eql '~1.1 Title: Miss'
          expect(actual_lines[79]).to eql '~1.2 First Names: annie'
          expect(actual_lines[80]).to eql '~1.3 Surname: schulist'
          expect(actual_lines[81]).to eql '~1.4 Date of Birth: 19/07/1988'
          expect(actual_lines[82]).to eql '~1.5 Address:'
          expect(actual_lines[83]).to eql 'Address 1: 3216'
          expect(actual_lines[84]).to eql 'Address 2: franecki turnpike'
          expect(actual_lines[85]).to eql 'Address 3: amaliahaven'
          expect(actual_lines[86]).to eql 'Address 4: washington'
          expect(actual_lines[87]).to eql 'Postcode: f3 6nl'
          expect(actual_lines[88]).to eql ''
          expect(actual_lines[89]).to eql ''
          expect(actual_lines[90]).to eql ''
          expect(actual_lines[91]).to eql '## Section et1a: claim'
          expect(actual_lines[92]).to eql ''
          expect(actual_lines[93]).to eql '~1.1 Title: Mrs'
          expect(actual_lines[94]).to eql '~1.2 First Names: thad'
          expect(actual_lines[95]).to eql '~1.3 Surname: johns'
          expect(actual_lines[96]).to eql '~1.4 Date of Birth: 14/06/1993'
          expect(actual_lines[97]).to eql '~1.5 Address:'
          expect(actual_lines[98]).to eql 'Address 1: 66462'
          expect(actual_lines[99]).to eql 'Address 2: austyn trafficway'
          expect(actual_lines[100]).to eql 'Address 3: lake valentin'
          expect(actual_lines[101]).to eql 'Address 4: new jersey'
          expect(actual_lines[102]).to eql 'Postcode: rt49 2qa'
          expect(actual_lines[103]).to eql ''
          expect(actual_lines[104]).to eql ''
          expect(actual_lines[105]).to eql ''
          expect(actual_lines[106]).to eql '## Section et1a: claim'
          expect(actual_lines[107]).to eql ''
          expect(actual_lines[108]).to eql '~1.1 Title: Miss'
          expect(actual_lines[109]).to eql '~1.2 First Names: coleman'
          expect(actual_lines[110]).to eql '~1.3 Surname: kreiger'
          expect(actual_lines[111]).to eql '~1.4 Date of Birth: 12/05/1960'
          expect(actual_lines[112]).to eql '~1.5 Address:'
          expect(actual_lines[113]).to eql 'Address 1: 934'
          expect(actual_lines[114]).to eql 'Address 2: whitney burgs'
          expect(actual_lines[115]).to eql 'Address 3: emmanuelhaven'
          expect(actual_lines[116]).to eql 'Address 4: alaska'
          expect(actual_lines[117]).to eql 'Postcode: td6b 6jj'
          expect(actual_lines[118]).to eql ''
          expect(actual_lines[119]).to eql ''
          expect(actual_lines[120]).to eql ''
          expect(actual_lines[121]).to eql '## Section et1a: claim'
          expect(actual_lines[122]).to eql ''
          expect(actual_lines[123]).to eql '~1.1 Title: Ms'
          expect(actual_lines[124]).to eql '~1.2 First Names: jensen'
          expect(actual_lines[125]).to eql '~1.3 Surname: deckow'
          expect(actual_lines[126]).to eql '~1.4 Date of Birth: 27/04/1970'
          expect(actual_lines[127]).to eql '~1.5 Address:'
          expect(actual_lines[128]).to eql 'Address 1: 1230'
          expect(actual_lines[129]).to eql 'Address 2: guiseppe courts'
          expect(actual_lines[130]).to eql 'Address 3: south candacebury'
          expect(actual_lines[131]).to eql 'Address 4: arkansas'
          expect(actual_lines[132]).to eql 'Postcode: u0p 6al'
          expect(actual_lines[133]).to eql ''
          expect(actual_lines[134]).to eql ''
          expect(actual_lines[135]).to eql ''
          expect(actual_lines[136]).to eql '## Section et1a: claim'
          expect(actual_lines[137]).to eql ''
          expect(actual_lines[138]).to eql '~1.1 Title: Mr'
          expect(actual_lines[139]).to eql '~1.2 First Names: darien'
          expect(actual_lines[140]).to eql '~1.3 Surname: bahringer'
          expect(actual_lines[141]).to eql '~1.4 Date of Birth: 29/06/1958'
          expect(actual_lines[142]).to eql '~1.5 Address:'
          expect(actual_lines[143]).to eql 'Address 1: 3497'
          expect(actual_lines[144]).to eql 'Address 2: wilkinson junctions'
          expect(actual_lines[145]).to eql 'Address 3: kihnview'
          expect(actual_lines[146]).to eql 'Address 4: hawaii'
          expect(actual_lines[147]).to eql 'Postcode: z2e 3wl'
          expect(actual_lines[148]).to eql ''
          expect(actual_lines[149]).to eql ''
          expect(actual_lines[150]).to eql ''
          expect(actual_lines[151]).to eql '## Section et1a: claim'
          expect(actual_lines[152]).to eql ''
          expect(actual_lines[153]).to eql '~1.1 Title: Mrs'
          expect(actual_lines[154]).to eql '~1.2 First Names: eulalia'
          expect(actual_lines[155]).to eql '~1.3 Surname: hammes'
          expect(actual_lines[156]).to eql '~1.4 Date of Birth: 04/10/1998'
          expect(actual_lines[157]).to eql '~1.5 Address:'
          expect(actual_lines[158]).to eql 'Address 1: 376'
          expect(actual_lines[159]).to eql 'Address 2: krajcik wall'
          expect(actual_lines[160]).to eql 'Address 3: south ottis'
          expect(actual_lines[161]).to eql 'Address 4: idaho'
          expect(actual_lines[162]).to eql 'Postcode: kg2 5aj'
          expect(actual_lines[163]).to eql ''
          expect(actual_lines[164]).to eql ''
          expect(actual_lines[165]).to eql ''
        end
        true
      end
    end
  end
end

def be_valid_et1a_claim_text(*args)
  ::EtApi::Test::BeValidEt1aClaimTextMatcher.new(*args)
end
