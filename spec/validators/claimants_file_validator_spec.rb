# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClaimantsFileValidator do
  describe '#valid?' do
    class self::ExampleClass < ApplicationRecord # rubocop:disable RSpec/LeakyConstantDeclaration, Lint/ConstantDefinitionInBlock, Style/ClassAndModuleChildren
      establish_connection adapter: :nulldb,
                           schema: 'config/nulldb_schema.rb'
      attribute :data_from_key, :string
      validates :data_from_key, claimants_file: true
    end

    subject(:model) { self.class::ExampleClass.new(data_from_key: direct_uploaded_file.file.key) }

    let(:direct_uploaded_file) { create(:direct_uploaded_file, :example_claim_claimants_csv, file_to_attach: { file: example_file, filename: 'example.csv', content_type: 'application/csv' }) }

    context 'when the file is a valid csv file' do
      let(:example_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/simple_user_with_csv_group_claims.csv'), 'text/csv', false) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors).to be_empty
      end
    end

    context 'when the file has missing address fields across multiple rows' do
      let(:example_file) do
        build(:claimants_file).tap do |file|
          file.claimants << build(:claimant, :tamara_swift).tap { |c| c.address.building = '' }
          file.claimants << build(:claimant, :tamara_swift).tap { |c| c.address.street = '' }
          file.claimants << build(:claimant, :tamara_swift).tap { |c| c.address.locality = '' }
          file.claimants << build(:claimant, :tamara_swift).tap { |c| c.address.county = '' }
          file.claimants << build(:claimant, :tamara_swift).tap { |c| c.address.post_code = '' }
        end.generate!
      end

      before { model.valid? }

      it 'disallows the file with the correct building error' do
        expect(model.errors.where(:'data_from_key[0].building', "can't be blank")).to be_present
      end

      it 'disallows the file with the correct street error' do
        expect(model.errors.where(:'data_from_key[1].street', "can't be blank")).to be_present
      end

      it 'disallows the file with the correct locality error' do
        expect(model.errors.where(:'data_from_key[2].locality', "can't be blank")).to be_present
      end

      it 'disallows the file with the correct county error' do
        expect(model.errors.where(:'data_from_key[3].county', "can't be blank")).to be_present
      end

      it 'disallows the file with the correct post code error' do
        expect(model.errors.where(:'data_from_key[4].post_code', "can't be blank")).to be_present
      end
    end
  end
end
