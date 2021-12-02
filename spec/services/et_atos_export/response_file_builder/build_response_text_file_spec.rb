require 'rails_helper'

RSpec.describe ::EtAtosExport::ResponseFileBuilder::BuildResponseTextFile do
  subject(:builder) { described_class }

  let(:errors) { [] }

  describe '#call' do
    shared_examples 'for any response variation' do
      it 'stores an ET3 txt file with the correct filename' do
        # Act
        builder.call(response)

        # Assert
        expect(response.uploaded_files.filter(&:system_file_scope?)).to include an_object_having_attributes filename: 'et3_atos_export.txt',
                                                                                                 file: be_a_stored_file

      end

      it 'stores an ET3 txt file with the correct structure' do
        # Act
        builder.call(response)
        response.save!

        # Assert
        uploaded_file = response.uploaded_files.system_file_scope.where(filename: 'et3_atos_export.txt').first
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, 'et3_atos_export.txt')
          uploaded_file.download_blob_to(full_path)
          File.open full_path do |file|
            et3_file = EtApi::Test::FileObjects::Et3TxtFile.new(file)
            expect(et3_file).to have_correct_file_structure(errors: errors)
          end
        end
      end

      it 'stores an ET3 txt file with the correct contents' do
        # Act
        builder.call(response)
        response.save!

        # Assert
        uploaded_file = response.uploaded_files.system_file_scope.where(filename: 'et3_atos_export.txt').first
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, 'et3_atos_export.txt')
          uploaded_file.download_blob_to(full_path)
          File.open full_path do |file|
            et3_file = EtApi::Test::FileObjects::Et3TxtFile.new(file)
            expect(et3_file).to have_correct_contents_from_db_for(errors: errors, response: response), -> { errors.join("\n") }
          end
        end
      end
    end

    context 'with a representative' do
      let(:response) { create(:response, :example_data, :with_representative) }

      include_examples 'for any response variation'
    end

    context 'without a representative' do
      let(:response) { create(:response, :example_data, :without_representative) }

      include_examples 'for any response variation'
    end
  end
end
