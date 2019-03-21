# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Claim, type: :model do
  subject(:example_address_attrs) { attributes_for :address }

  let(:claim) { described_class.new attributes_for(:claim) }

  describe '#primary_claimant' do
    it 'returns claim - claimant built in memory' do
      # Arrange
      claim.build_primary_claimant title: 'Mr',
                                   first_name: 'Fred',
                                   last_name: 'Bloggs',
                                   address_attributes: example_address_attrs

      # Act
      result = claim.primary_claimant

      # Assert
      expect(result).to have_attributes first_name: 'Fred', last_name: 'Bloggs'
    end
  end

  describe '#secondary_claimants' do
    it 'returns claim - claimants built in memory' do
      # Arrange
      claim.secondary_claimants_attributes = [
        {
          title: 'Mr',
          first_name: 'Fred',
          last_name: 'Bloggs',
          address_attributes: example_address_attrs
        }
      ]

      # Act
      results = claim.secondary_claimants

      # Assert
      expect(results).to contain_exactly an_object_having_attributes first_name: 'Fred', last_name: 'Bloggs'
    end
  end

  describe '#primary_respondent' do
    it 'returns respondent built in memory' do
      # Arrange
      claim.build_primary_respondent name: 'Fred Bloggs',
                                     address_attributes: example_address_attrs,
                                     work_address_telephone_number: '03333 423554',
                                     address_telephone_number: '02222 321654',
                                     acas_number: 'AC123456/78/90',
                                     work_address_attributes: example_address_attrs,
                                     alt_phone_number: '03333 423554'

      # Assert - Validate the results
      expect(claim.primary_respondent).to have_attributes name: 'Fred Bloggs'
    end
  end

  describe '#secondary_respondents' do
    it 'returns respondents built in memory' do
      # Arrange
      claim.secondary_respondents.build name: 'Fred Bloggs',
                                        address_attributes: example_address_attrs,
                                        work_address_telephone_number: '03333 423554',
                                        address_telephone_number: '02222 321654',
                                        acas_number: 'AC123456/78/90',
                                        work_address_attributes: example_address_attrs,
                                        alt_phone_number: '03333 423554'

      # Assert - Validate the results
      expect(claim.secondary_respondents).to contain_exactly an_object_having_attributes name: 'Fred Bloggs'
    end
  end

  describe '#primary_representative' do
    it 'returns representative built in memory' do
      # Arrange
      claim.build_primary_representative name: 'Solicitor Name',
                                         organisation_name: 'Solicitors Are Us Fake Company',
                                         address_attributes: example_address_attrs,
                                         address_telephone_number: '01111 123456',
                                         mobile_number: '02222 654321',
                                         email_address: 'solicitor.test@digital.justice.gov.uk',
                                         representative_type: 'Solicitor',
                                         dx_number: 'dx1234567890'
      # Act
      rep = claim.primary_representative

      # Assert
      expect(rep).to have_attributes name: 'Solicitor Name'
    end
  end

  describe '#secondary_representatives' do
    it 'returns representatives built in memory' do
      # Arrange
      claim.secondary_representatives.build name: 'Solicitor Name',
                                            organisation_name: 'Solicitors Are Us Fake Company',
                                            address_attributes: example_address_attrs,
                                            address_telephone_number: '01111 123456',
                                            mobile_number: '02222 654321',
                                            email_address: 'solicitor.test@digital.justice.gov.uk',
                                            representative_type: 'Solicitor',
                                            dx_number: 'dx1234567890'
      # Act
      reps = claim.secondary_representatives

      # Assert
      expect(reps).to contain_exactly an_object_having_attributes name: 'Solicitor Name'
    end
  end

  describe '#uploaded_files' do
    it 'returns uploaded files built in memory' do
      # Act
      claim.uploaded_files_attributes = [
        {
          filename: 'et1_first_last.pdf',
          checksum: 'ee2714b8b731a8c1e95dffaa33f89728',
          file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'et1_first_last.pdf'), 'application/pdf')
        }
      ]

      # Assert
      expect(claim.uploaded_files).to contain_exactly an_object_having_attributes filename: 'et1_first_last.pdf'
    end
  end

  describe 'claimant_count' do
    it 'returns the number of claimants built at initialisation time' do
      # Arrange
      claim.primary_claimant_attributes = {
        title: 'Mr',
        first_name: 'Fred',
        last_name: 'Bloggs',
        address_attributes: example_address_attrs
      }
      claim.secondary_claimants_attributes = [
        {
          title: 'Mrs',
          first_name: 'Sara',
          last_name: 'Bloggs',
          address_attributes: example_address_attrs
        }
      ]

      # Act
      claim.save(validate: false)

      # Assert
      expect(claim.claimant_count).to be 2
    end

    it 'returns the number of claimants when loaded from database and then saved with no changes to claimants' do
      # Arrange - Use a factory to create a record in the database
      id = create(:claim, number_of_claimants: 3).id
      claim = described_class.find(id)

      # Act - make a change
      claim.claimant_count = 100
      claim.save(validate: false)

      # Assert - Make sure it is correct
      expect(claim.claimant_count).to be 3
    end
  end

  # @TODO RST-1014 - Security - make sure first and last names cannot contain anything that might screw up the file copying
end
