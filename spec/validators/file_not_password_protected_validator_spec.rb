# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileNotPasswordProtectedValidator do
  include_context 'with local storage'

  describe '#valid?' do
    class self::ExampleClass < ApplicationRecord # rubocop:disable Lint/ConstantDefinitionInBlock, Style/ClassAndModuleChildren
      establish_connection adapter: :nulldb,
                           schema: 'config/nulldb_schema.rb'
      attribute :data_from_key, :string
      validates :data_from_key, file_not_password_protected: true
    end

    subject(:model) { self.class::ExampleClass.new(data_from_key: direct_uploaded_file.file.key) }

    context 'when the file is a password protected pdf file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :password_protected_pdf) }

      before { model.valid? }

      it 'disallows the file' do
        expect(model.errors.where(:data_from_key, :password_protected)).to be_present
      end

      it 'has the expected validation message' do
        expect(model.errors.full_messages).to include("Data from key This file is password protected. Upload a file that isn’t password protected.")
      end
    end

    context 'when the file is an unprotected pdf file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :plain_pdf) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is a password protected doc file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :password_protected_doc) }

      before { model.valid? }

      it 'disallows the file' do
        expect(model.errors.where(:data_from_key, :password_protected)).to be_present
      end
    end

    context 'when the file is an unprotected doc file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :plain_doc) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is a password protected docx file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :password_protected_docx) }

      before { model.valid? }

      it 'disallows the file' do
        expect(model.errors.where(:data_from_key, :password_protected)).to be_present
      end
    end

    context 'when the file is an unprotected docx file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :plain_docx) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is a password protected xls file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :password_protected_xls) }

      before { model.valid? }

      it 'disallows the file' do
        expect(model.errors.where(:data_from_key, :password_protected)).to be_present
      end
    end

    context 'when the file is an unprotected xls file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :plain_xls) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is a password protected xlsx file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :password_protected_xlsx) }

      before { model.valid? }

      it 'disallows the file' do
        expect(model.errors.where(:data_from_key, :password_protected)).to be_present
      end
    end

    context 'when the file is an unprotected xlsx file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :plain_xlsx) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is a password protected ppt file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :password_protected_ppt) }

      before { model.valid? }

      it 'disallows the file' do
        expect(model.errors.where(:data_from_key, :password_protected)).to be_present
      end
    end

    context 'when the file is an unprotected ppt file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :plain_ppt) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is a password protected pptx file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :password_protected_pptx) }

      before { model.valid? }

      it 'disallows the file' do
        expect(model.errors.where(:data_from_key, :password_protected)).to be_present
      end
    end

    context 'when the file is an unprotected pptx file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :plain_pptx) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is an rtf file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :example_claim_rtf) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is a csv file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :example_claim_claimants_csv) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is a txt file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :example_claim_text) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end

    context 'when the file is a jpg file' do
      let(:direct_uploaded_file) { create(:direct_uploaded_file, :plain_jpg) }

      before { model.valid? }

      it 'allows the file' do
        expect(model.errors.where(:data_from_key)).to be_empty
      end
    end
  end
end
