# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClaimXmlImportService do
  let(:reference) { '222000000300' }
  let(:simple_example_data) do
    <<~XML

      <ETFeesEntry xmlns="http://www.justice.gov.uk/ETFEES" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xsi:noNamespaceSchemaLocation="ETFees_v0.24.xsd">
        <DocumentId>
          <DocumentName>ETFeesEntry</DocumentName>
          <UniqueId>20180329164627</UniqueId>
          <DocumentType>ETFeesEntry</DocumentType>
          <TimeStamp>2018-03-29T16:46:27+01:00</TimeStamp>
          <Version>1</Version>
        </DocumentId>
        <FeeGroupReference>#{reference}</FeeGroupReference>
        <SubmissionUrn>J704-ZK5E</SubmissionUrn>
        <CurrentQuantityOfClaimants>1</CurrentQuantityOfClaimants>
        <SubmissionChannel>Web</SubmissionChannel>
        <CaseType>Single</CaseType>
        <Jurisdiction>2</Jurisdiction>
        <OfficeCode>22</OfficeCode>
        <DateOfReceiptEt>2018-03-29T16:46:26+01:00</DateOfReceiptEt>
        <RemissionIndicated>NotRequested</RemissionIndicated>
        <Administrator>-1</Administrator>
        <Claimants>
          <Claimant>
            <GroupContact>true</GroupContact>
            <Title>Mr</Title>
            <Forename>First</Forename>
            <Surname>Last</Surname>
            <Address>
              <Line>102</Line>
              <Street>Petty France</Street>
              <Town>London</Town>
              <County>Greater London</County>
              <Postcode>SW1H 9AJ</Postcode>
            </Address>
            <OfficeNumber>01234 567890</OfficeNumber>
            <AltPhoneNumber>01234 098765</AltPhoneNumber>
            <Email>test@digital.justice.gov.uk</Email>
            <Fax/>
            <PreferredContactMethod>Email</PreferredContactMethod>
            <Sex>Male</Sex>
            <DateOfBirth>21/11/1982</DateOfBirth>
          </Claimant>
        </Claimants>
        <Respondents>
          <Respondent>
            <GroupContact>true</GroupContact>
            <Name>Respondent Name</Name>
            <Address>
              <Line>108</Line>
              <Street>Regent Street</Street>
              <Town>London</Town>
              <County>Greater London</County>
              <Postcode>SW1H 9QR</Postcode>
            </Address>
            <OfficeNumber>03333 423554</OfficeNumber>
            <PhoneNumber>02222 321654</PhoneNumber>
            <Acas>
              <Number>AC123456/78/90</Number>
            </Acas>
            <AltAddress>
              <Line>110</Line>
              <Street>Piccadily Circus</Street>
              <Town>London</Town>
              <County>Greater London</County>
              <Postcode>SW1H 9ST</Postcode>
            </AltAddress>
            <AltPhoneNumber>03333 423554</AltPhoneNumber>
          </Respondent>
        </Respondents>
        <Representatives>
          <Representative>
            <Name>Solicitor Name</Name>
            <Organisation>Solicitors Are Us Fake Company</Organisation>
            <Address>
              <Line>106</Line>
              <Street>Mayfair</Street>
              <Town>London</Town>
              <County>Greater London</County>
              <Postcode>SW1H 9PP</Postcode>
            </Address>
            <OfficeNumber>01111 123456</OfficeNumber>
            <AltPhoneNumber>02222 654321</AltPhoneNumber>
            <Email>solicitor.test@digital.justice.gov.uk</Email>
            <ClaimantOrRespondent>C</ClaimantOrRespondent>
            <Type>Solicitor</Type>
            <DXNumber>dx1234567890</DXNumber>
          </Representative>
        </Representatives>
        <Payment>
          <Fee>
            <Amount>0</Amount>
            <PRN>222000000300</PRN>
            <Date>2018-03-29T16:46:26+01:00</Date>
          </Fee>
        </Payment>
        <Files>
          <File>
            <Filename>et1_first_last.pdf</Filename>
            <Checksum>ee2714b8b731a8c1e95dffaa33f89728</Checksum>
          </File>
        </Files>
      </ETFeesEntry>
    XML
  end
  let(:simple_example_input_files) do
    {
      'et1_first_last.pdf' => {
        filename: 'et1_first_last.pdf',
        checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
        file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf')
      }
    }
  end

  describe '#files' do
    subject(:service) { described_class.new(simple_example_data) }

    it 'fetches the value from the xml data' do
      # Act
      result = service.files

      # Assert - make sure only the files listed in the xml are provided
      expect(result).to contain_exactly a_hash_including(filename: 'et1_first_last.pdf', checksum: 'ee2714b8b731a8c1e95dffaa33f89728')
    end
  end

  describe '#uploaded_files=' do
    subject(:service) { described_class.new(simple_example_data) }

    it 'persists them in the instance' do
      service.uploaded_files = { anything: :goes }
      expect(service.uploaded_files).to eql(anything: :goes)
    end
  end

  describe 'import' do
    subject(:service) { described_class.new(simple_example_data).tap { |s| s.uploaded_files = simple_example_input_files } }

    it 'creates a new claim' do
      expect { service.import }.to change(Claim, :count).by(1)
    end

    it 'converts the root data correctly' do
      # Act
      service.import

      # Assert
      claim = Claim.where(reference: reference).first
      expect(claim).to have_attributes reference: reference,
                                       submission_reference: 'J704-ZK5E',
                                       claimant_count: 1,
                                       submission_channel: 'Web',
                                       case_type: 'Single',
                                       jurisdiction: 2,
                                       office_code: 22,
                                       date_of_receipt: Time.zone.parse('2018-03-29T16:46:26+01:00'),
                                       administrator: false
    end

    it 'converts the claimants correctly' do
      # Act
      service.import

      # Assert
      claim = Claim.where(reference: reference).first
      expect(claim.claimants).to contain_exactly an_object_having_attributes title: 'Mr',
                                                                             first_name: 'First',
                                                                             last_name: 'Last',
                                                                             address: an_object_having_attributes(
                                                                               building: '102',
                                                                               street: 'Petty France',
                                                                               locality: 'London',
                                                                               county: 'Greater London',
                                                                               post_code: 'SW1H 9AJ'
                                                                             ),
                                                                             address_telephone_number: '01234 567890',
                                                                             mobile_number: '01234 098765',
                                                                             email_address: 'test@digital.justice.gov.uk',
                                                                             contact_preference: 'Email',
                                                                             gender: 'Male',
                                                                             date_of_birth: Date.parse('21/11/1982')
    end

    it 'converts the respondents correctly' do
      # Act
      service.import

      # Assert
      claim = Claim.where(reference: reference).first
      expect(claim.respondents).to contain_exactly an_object_having_attributes name: 'Respondent Name',
                                                                               address: an_object_having_attributes(
                                                                                 building: '108',
                                                                                 street: 'Regent Street',
                                                                                 locality: 'London',
                                                                                 county: 'Greater London',
                                                                                 post_code: 'SW1H 9QR'
                                                                               ),
                                                                               work_address_telephone_number: '03333 423554',
                                                                               address_telephone_number: '02222 321654',
                                                                               acas_number: 'AC123456/78/90',
                                                                               work_address: an_object_having_attributes(
                                                                                 building: '110',
                                                                                 street: 'Piccadily Circus',
                                                                                 locality: 'London',
                                                                                 county: 'Greater London',
                                                                                 post_code: 'SW1H 9ST'
                                                                               ),
                                                                               alt_phone_number: '03333 423554'
    end

    it 'converts the representatives correctly' do
      # Act
      service.import

      # Assert
      claim = Claim.where(reference: reference).first
      expect(claim.representatives).to contain_exactly an_object_having_attributes name: 'Solicitor Name',
                                                                                   organisation_name: 'Solicitors Are Us Fake Company',
                                                                                   address: an_object_having_attributes(
                                                                                     building: '106',
                                                                                     street: 'Mayfair',
                                                                                     locality: 'London',
                                                                                     county: 'Greater London',
                                                                                     post_code: 'SW1H 9PP'
                                                                                   ),
                                                                                   address_telephone_number: '01111 123456',
                                                                                   mobile_number: '02222 654321',
                                                                                   email_address: 'solicitor.test@digital.justice.gov.uk',
                                                                                   representative_type: 'solicitor',
                                                                                   dx_number: 'dx1234567890'

    end

    it 'converts the files correctly' do
      # Act
      service.import

      # Assert

      claim = Claim.find_by(reference: reference)
      expect(claim.uploaded_files).to include an_object_having_attributes filename: 'et1_first_last.pdf',
                                                                          checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
                                                                          file: be_a_stored_file
    end

    it 'stores the xml in a file' do
      # Act
      service.import

      # Assert
      claim = Claim.find_by(reference: reference)
      expect(claim.uploaded_files).to include an_object_having_attributes filename: 'et1_First_Last.xml',
                                                                          file: be_a_stored_file
    end

    it 'stores the xml as a byte for byte copy' do
      # Act
      service.import

      # Assert
      claim = Claim.find_by(reference: reference)
      expect(claim.uploaded_files).to include an_object_having_attributes filename: 'et1_First_Last.xml',
                                                                          file: be_a_stored_file_with_contents(simple_example_data)
    end

    it 'stores an ET1 txt file with the correct filename' do
      # Act
      service.import

      # Assert
      claim = Claim.find_by(reference: reference)
      expect(claim.uploaded_files).to include an_object_having_attributes filename: 'et1_First_Last.txt',
                                                                          file: be_a_stored_file

    end

    it 'stores an ET1 txt file with the correct contents' do
      # Act
      service.import

      # Assert
      claim = Claim.find_by(reference: reference)
      uploaded_file = claim.uploaded_files.where(filename: 'et1_First_Last.txt').first
      expect(uploaded_file.file.download).to be_valid_et1_claim_text
    end

    it 'does not store an ET1a txt file' do
      # Act
      service.import

      # Assert
      claim = Claim.find_by(reference: reference)
      uploaded_file = claim.uploaded_files.where(filename: 'et1a_First_Last.txt').first
      expect(uploaded_file).to be_nil
    end

    context 'with > 7 claimants uploaded via csv file from front end' do
      let(:simple_example_data) do
        <<~XML
          <ETFeesEntry xmlns="http://www.justice.gov.uk/ETFEES" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xsi:noNamespaceSchemaLocation="ETFees_v0.24.xsd">
            <DocumentId>
              <DocumentName>ETFeesEntry</DocumentName>
              <UniqueId>20180329164627</UniqueId>
              <DocumentType>ETFeesEntry</DocumentType>
              <TimeStamp>2018-03-29T16:46:27+01:00</TimeStamp>
              <Version>1</Version>
            </DocumentId>
            <FeeGroupReference>222000000300</FeeGroupReference>
            <SubmissionUrn>J704-ZK5E</SubmissionUrn>
            <CurrentQuantityOfClaimants>1</CurrentQuantityOfClaimants>
            <SubmissionChannel>Web</SubmissionChannel>
            <CaseType>Multiple</CaseType>
            <Jurisdiction>2</Jurisdiction>
            <OfficeCode>22</OfficeCode>
            <DateOfReceiptEt>2018-03-29T16:46:26+01:00</DateOfReceiptEt>
            <RemissionIndicated>NotRequested</RemissionIndicated>
            <Administrator>-1</Administrator>
            <Claimants>
              <Claimant>
                <GroupContact>true</GroupContact>
                <Title>Mr</Title>
                <Forename>First</Forename>
                <Surname>Last</Surname>
                <Address>
                  <Line>102</Line>
                  <Street>Petty France</Street>
                  <Town>London</Town>
                  <County>Greater London</County>
                  <Postcode>SW1H 9AJ</Postcode>
                </Address>
                <OfficeNumber>01234 567890</OfficeNumber>
                <AltPhoneNumber>01234 098765</AltPhoneNumber>
                <Email>test@digital.justice.gov.uk</Email>
                <Fax/>
                <PreferredContactMethod>Email</PreferredContactMethod>
                <Sex>Male</Sex>
                <DateOfBirth>21/11/1982</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Mrs</Title>
                <Forename>tamara</Forename>
                <Surname>swift</Surname>
                <Address>
                  <Line>71088</Line>
                  <Street>nova loaf</Street>
                  <Town>keelingborough</Town>
                  <County>hawaii</County>
                  <Postcode>yy9a 2la</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>06/07/1957</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Mr</Title>
                <Forename>diana</Forename>
                <Surname>flatley</Surname>
                <Address>
                  <Line>66262</Line>
                  <Street>feeney station</Street>
                  <Town>west jewelstad</Town>
                  <County>montana</County>
                  <Postcode>r8p 0jb</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>24/09/1986</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Ms</Title>
                <Forename>mariana</Forename>
                <Surname>mccullough</Surname>
                <Address>
                  <Line>819</Line>
                  <Street>mitchell glen</Street>
                  <Town>east oliverton</Town>
                  <County>south carolina</County>
                  <Postcode>uh2 4na</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>10/08/1992</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Mr</Title>
                <Forename>eden</Forename>
                <Surname>upton</Surname>
                <Address>
                  <Line>272</Line>
                  <Street>hoeger lodge</Street>
                  <Town>west roxane</Town>
                  <County>new mexico</County>
                  <Postcode>pd3p 8ns</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>09/01/1965</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Miss</Title>
                <Forename>annie</Forename>
                <Surname>schulist</Surname>
                <Address>
                  <Line>3216</Line>
                  <Street>franecki turnpike</Street>
                  <Town>amaliahaven</Town>
                  <County>washington</County>
                  <Postcode>f3 6nl</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>19/07/1988</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Mrs</Title>
                <Forename>thad</Forename>
                <Surname>johns</Surname>
                <Address>
                  <Line>66462</Line>
                  <Street>austyn trafficway</Street>
                  <Town>lake valentin</Town>
                  <County>new jersey</County>
                  <Postcode>rt49 2qa</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>14/06/1993</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Miss</Title>
                <Forename>coleman</Forename>
                <Surname>kreiger</Surname>
                <Address>
                  <Line>934</Line>
                  <Street>whitney burgs</Street>
                  <Town>emmanuelhaven</Town>
                  <County>alaska</County>
                  <Postcode>td6b 6jj</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>12/05/1960</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Ms</Title>
                <Forename>jensen</Forename>
                <Surname>deckow</Surname>
                <Address>
                  <Line>1230</Line>
                  <Street>guiseppe courts</Street>
                  <Town>south candacebury</Town>
                  <County>arkansas</County>
                  <Postcode>u0p 6al</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>27/04/1970</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Mr</Title>
                <Forename>darien</Forename>
                <Surname>bahringer</Surname>
                <Address>
                  <Line>3497</Line>
                  <Street>wilkinson junctions</Street>
                  <Town>kihnview</Town>
                  <County>hawaii</County>
                  <Postcode>z2e 3wl</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>29/06/1958</DateOfBirth>
              </Claimant>
              <Claimant>
                <GroupContact>false</GroupContact>
                <Title>Mrs</Title>
                <Forename>eulalia</Forename>
                <Surname>hammes</Surname>
                <Address>
                  <Line>376</Line>
                  <Street>krajcik wall</Street>
                  <Town>south ottis</Town>
                  <County>idaho</County>
                  <Postcode>kg2 5aj</Postcode>
                </Address>
                <OfficeNumber/>
                <AltPhoneNumber/>
                <Email/>
                <Fax/>
                <PreferredContactMethod/>
                <Sex/>
                <DateOfBirth>04/10/1998</DateOfBirth>
              </Claimant>
            </Claimants>
            <Respondents>
              <Respondent>
                <GroupContact>true</GroupContact>
                <Name>Respondent Name</Name>
                <Address>
                  <Line>108</Line>
                  <Street>Regent Street</Street>
                  <Town>London</Town>
                  <County>Greater London</County>
                  <Postcode>SW1H 9QR</Postcode>
                </Address>
                <OfficeNumber>03333 423554</OfficeNumber>
                <PhoneNumber>02222 321654</PhoneNumber>
                <Acas>
                  <Number>AC123456/78/90</Number>
                </Acas>
                <AltAddress>
                  <Line>110</Line>
                  <Street>Piccadily Circus</Street>
                  <Town>London</Town>
                  <County>Greater London</County>
                  <Postcode>SW1H 9ST</Postcode>
                </AltAddress>
                <AltPhoneNumber>03333 423554</AltPhoneNumber>
              </Respondent>
            </Respondents>
            <Representatives>
              <Representative>
                <Name>Solicitor Name</Name>
                <Organisation>Solicitors Are Us Fake Company</Organisation>
                <Address>
                  <Line>106</Line>
                  <Street>Mayfair</Street>
                  <Town>London</Town>
                  <County>Greater London</County>
                  <Postcode>SW1H 9PP</Postcode>
                </Address>
                <OfficeNumber>01111 123456</OfficeNumber>
                <AltPhoneNumber>02222 654321</AltPhoneNumber>
                <Email>solicitor.test@digital.justice.gov.uk</Email>
                <ClaimantOrRespondent>C</ClaimantOrRespondent>
                <Type>Solicitor</Type>
                <DXNumber>dx1234567890</DXNumber>
              </Representative>
            </Representatives>
            <Payment>
              <Fee>
                <Amount>0</Amount>
                <PRN>222000001600</PRN>
                <Date>2018-04-24T14:04:42+01:00</Date>
              </Fee>
            </Payment>
            <Files>
              <File>
                <Filename>simple_user_with_csv_group_claims.csv</Filename>
                <Checksum>7ac66d9f4af3b498e4cf7b9430974618</Checksum>
              </File>
              <File>
                <Filename>et1_first_last.pdf</Filename>
                <Checksum>ee2714b8b731a8c1e95dffaa33f89728</Checksum>
              </File>
            </Files>
          </ETFeesEntry>

        XML
      end
      let(:simple_example_input_files) do
        {
          'et1_first_last.pdf' => {
            filename: 'et1_first_last.pdf',
            checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
            file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf')
          }
        }
      end

      it 'converts the root data correctly' do
        # Act
        service.import

        # Assert
        claim = Claim.where(reference: reference).first
        expect(claim).to have_attributes reference: reference,
                                         submission_reference: 'J704-ZK5E',
                                         claimant_count: 11,
                                         submission_channel: 'Web',
                                         case_type: 'Multiple',
                                         jurisdiction: 2,
                                         office_code: 22,
                                         date_of_receipt: Time.zone.parse('2018-03-29T16:46:26+01:00'),
                                         administrator: false
      end

      it 'imports all claimants' do
        # Act
        service.import

        # Assert
        claim = Claim.where(reference: reference).first
        expect(claim.claimants).to contain_exactly an_object_having_attributes(title: 'Mr', first_name: 'First', last_name: 'Last'),
                                                   an_object_having_attributes(title: 'Mrs', first_name: 'tamara', last_name: 'swift'),
                                                   an_object_having_attributes(title: 'Mr', first_name: 'diana', last_name: 'flatley'),
                                                   an_object_having_attributes(title: 'Ms', first_name: 'mariana', last_name: 'mccullough'),
                                                   an_object_having_attributes(title: 'Mr', first_name: 'eden', last_name: 'upton'),
                                                   an_object_having_attributes(title: 'Miss', first_name: 'annie', last_name: 'schulist'),
                                                   an_object_having_attributes(title: 'Mrs', first_name: 'thad', last_name: 'johns'),
                                                   an_object_having_attributes(title: 'Miss', first_name: 'coleman', last_name: 'kreiger'),
                                                   an_object_having_attributes(title: 'Ms', first_name: 'jensen', last_name: 'deckow'),
                                                   an_object_having_attributes(title: 'Mr', first_name: 'darien', last_name: 'bahringer'),
                                                   an_object_having_attributes(title: 'Mrs', first_name: 'eulalia', last_name: 'hammes')

      end

      it 'stores an ET1a txt file with the correct filename' do
        # Act
        service.import

        # Assert
        claim = Claim.find_by(reference: reference)
        expect(claim.uploaded_files).to include an_object_having_attributes filename: 'et1a_First_Last.txt',
                                                                            file: be_a_stored_file
      end

      it 'stores an ET1a txt file with the correct contents' do
        # Act
        service.import

        # Assert
        claim = Claim.find_by(reference: reference)
        uploaded_file = claim.uploaded_files.where(filename: 'et1a_First_Last.txt').first
        expect(uploaded_file.file.download).to be_valid_et1a_claim_text
      end
    end



    # @TODO Make sure validation is covered
  end
end
