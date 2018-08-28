# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClaimXmlImportService do
  let(:reference) { '222000000300' }
  let(:simple_example_data) { build(:xml_claim, :simple_user).to_xml }
  let(:simple_example_input_files) do
    {
      'et1_first_last.pdf' => {
        filename: 'et1_first_last.pdf',
        checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
        file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf')
      }
    }
  end
  let(:mock_file_builder_class) { class_spy('ClaimFileBuilderService', new: mock_file_builder_service) }
  let(:mock_file_builder_service) { instance_spy('ClaimFileBuilderService') }

  describe '#files' do
    subject(:service) { described_class.new(simple_example_data, file_builder_service: mock_file_builder_class) }

    it 'fetches the value from the xml data' do
      # Act
      result = service.files

      # Assert - make sure only the files listed in the xml are provided
      expect(result).to contain_exactly a_hash_including(filename: 'et1_first_last.pdf', checksum: 'ee2714b8b731a8c1e95dffaa33f89728')
    end
  end

  describe '#uploaded_files=' do
    subject(:service) { described_class.new(simple_example_data, file_builder_service: mock_file_builder_class) }

    it 'persists them in the instance' do
      service.uploaded_files = { anything: :goes }
      expect(service.uploaded_files).to eql(anything: :goes)
    end
  end

  describe 'import' do
    subject(:service) { described_class.new(simple_example_data, file_builder_service: mock_file_builder_class).tap { |s| s.uploaded_files = simple_example_input_files } }

    let(:destination_claim) { Claim.new }

    context 'with single claimant, respondent and representative' do
      it 'creates a new claim' do
        expect { service.import(into: destination_claim) }.to change(Claim, :count).by(1)
      end

      it 'converts the root data correctly' do
        # Act
        service.import(into: destination_claim)

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
        service.import(into: destination_claim)

        # Assert
        claim = Claim.where(reference: reference).first
        expect(claim.claim_claimants).to contain_exactly an_object_having_attributes primary: true,
                                                                                     claimant: an_object_having_attributes(title: 'Mr',
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
                                                                                                                           date_of_birth: Date.parse('21/11/1982'))
      end

      it 'converts the primary claimant correctly' do
        # Act
        service.import(into: destination_claim)

        # Assert
        claim = Claim.where(reference: reference).first
        expect(claim.primary_claimant).to have_attributes title: 'Mr',
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
        service.import(into: destination_claim)

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
        service.import(into: destination_claim)

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
                                                                                     representative_type: 'Solicitor',
                                                                                     dx_number: 'dx1234567890'

      end

      it 'converts the files correctly' do
        # Act
        service.import(into: destination_claim)

        # Assert

        claim = Claim.find_by(reference: reference)
        expect(claim.uploaded_files).to include an_object_having_attributes filename: 'et1_first_last.pdf',
                                                                            checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
                                                                            file: be_a_stored_file
      end

      it 'calls the file builder to build the rest' do
        # Act
        service.import(into: destination_claim)

        # Assert
        aggregate_failures 'ensure file builder was called with a claim' do
          expect(mock_file_builder_class).to have_received(:new).with(an_instance_of(Claim))
          expect(mock_file_builder_service).to have_received(:call)
        end
      end
    end

    context 'with > 7 claimants uploaded via csv file from front end' do
      let(:simple_example_data) { build(:xml_claim, :simple_user_with_csv).to_xml }
      let(:simple_example_input_files) do
        {
          'et1_first_last.pdf' => {
            filename: 'et1_first_last.pdf',
            checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
            file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf')
          },
          'simple_user_with_csv_group_claims.csv' => {
            filename: 'simple_user_with_csv_group_claims.csv',
            checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
            file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'simple_user_with_csv_group_claims.csv'), 'text/csv')
          }
        }
      end

      it 'converts the root data correctly' do
        # Act
        service.import(into: destination_claim)

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
        service.import(into: destination_claim)

        # Assert
        claim = Claim.where(reference: reference).first
        expect(claim.claim_claimants.map(&:claimant)).to contain_exactly an_object_having_attributes(title: 'Mr', first_name: 'First', last_name: 'Last'),
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

      it 'converts the files correctly with the csv renamed' do
        # Act
        service.import(into: destination_claim)

        # Assert

        claim = Claim.find_by(reference: reference)
        expect(claim.uploaded_files).to include \
          an_object_having_attributes(filename: 'et1_first_last.pdf',
                                      checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
                                      file: be_a_stored_file),
          an_object_having_attributes(filename: 'et1a_First_Last.csv',
                                      checksum: '7ac66d9f4af3b498e4cf7b9430974618',
                                      file: be_a_stored_file)
      end

      it 'calls the file builder to build the rest' do
        # Act
        service.import(into: destination_claim)

        # Assert
        aggregate_failures 'ensure file builder was called with a claim' do
          expect(mock_file_builder_class).to have_received(:new).with(an_instance_of(Claim))
          expect(mock_file_builder_service).to have_received(:call)
        end
      end
    end

    context 'with single claimant, respondent, representative and an uploaded rtf file' do
      let(:simple_example_data) { build(:xml_claim, :simple_user_with_rtf).to_xml }
      let(:simple_example_input_files) do
        {
          'et1_first_last.pdf' => {
            filename: 'et1_first_last.pdf',
            checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
            file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf')
          },
          'simple_user_with_rtf.rtf' => {
            filename: 'simple_user_with_rtf.rtf',
            checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
            file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'simple_user_with_rtf.rtf'), 'application/rtf')
          }
        }
      end

      it 'converts the files correctly after renaming the rtf file' do
        # Act
        service.import(into: destination_claim)

        # Assert

        claim = Claim.find_by(reference: reference)
        expect(claim.uploaded_files).to include \
          an_object_having_attributes(filename: 'et1_first_last.pdf',
                                      checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
                                      file: be_a_stored_file),
          an_object_having_attributes(filename: 'et1_attachment_First_Last.rtf',
                                      checksum: 'e69a0344620b5040b7d0d1595b9c7726',
                                      file: be_a_stored_file)
      end
    end
    # @TODO Make sure validation is covered
  end
end
