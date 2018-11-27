require 'rails_helper'

module EtAtosExport
  RSpec.describe ResponseFileBuilderService do
    subject(:service) do
      described_class.new response,
        response_text_file_builder: response_text_file_builder_spy

    end

    # Setup for all
    # Spies for the builders which return nothing
    let(:response_text_file_builder_spy) { class_spy('::ClaimFileBuilder::BuildResponseTextFile') }

    describe '#call' do
      let(:response) { build(:response) }

      it 'calls the response text file builder' do
        # Act
        service.call

        # Assert
        expect(response_text_file_builder_spy).to have_received(:call)
      end
    end
  end
end
