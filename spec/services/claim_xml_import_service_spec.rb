# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClaimXmlImportService do
  let(:reference) { '222000000300' }
  let(:simple_example_data) do
    <<~EOS

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
    EOS
  end
  describe '#files' do
    subject(:service) { described_class.new(simple_example_data) }

    it 'fetches the value from the xml data' do
      # Act
      result = subject.files

      # Assert - make sure only the files listed in the xml are provided
      expect(result).to contain_exactly a_hash_including(filename: 'et1_first_last.pdf', checksum: 'ee2714b8b731a8c1e95dffaa33f89728')
    end
  end

  describe 'import' do
    subject(:service) { described_class.new(simple_example_data) }

    it 'creates a new claim' do
      expect { subject.import }.to change(Claim, :count).by(1)
    end

    it 'converts the root data correctly' do
      # Act
      subject.import

      # Assert
      claim = Claim.where(reference: reference).first
      expect(claim).to have_attributes reference: reference,
                                       submission_reference: 'J704-ZK5E',
                                       claimant_count: 1,
                                       submission_channel: 'Web',
                                       case_type: 'Single',
                                       jurisdiction: 2,
                                       office_code: 22,
                                       date_of_receipt: DateTime.parse('2018-03-29T16:46:26+01:00'),
                                       administrator: false
    end

    it 'converts the claimants correctly' do
      # Act
      subject.import

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
      subject.import

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
    # @TODO Make sure validation is covered
  end
end
