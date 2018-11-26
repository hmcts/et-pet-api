require 'rails_helper'

module EtAtosExport
  RSpec.describe ResponseFileBuilderService do
    subject(:service) do
      described_class.new response,
        response_text_file_builder: response_text_file_builder_spy,
        response_pdf_file_builder: response_pdf_file_builder_spy,
        response_rtf_file_builder: response_rtf_file_builder_spy

    end

    # Setup for all
    # Spies for the builders which return nothing
    let(:response_text_file_builder_spy) { class_spy('::EtAtosExport::ClaimFileBuilder::BuildResponseTextFile') }
    let(:response_pdf_file_builder_spy) { class_spy('::EtAtosExport::ClaimFileBuilder::BuildResponsePdfFile') }
    let(:response_rtf_file_builder_spy) { class_spy('::EtAtosExport::ClaimFileBuilder::BuildResponseRtfFile') }

    describe '#call' do
      let(:response) { build(:response) }

      it 'calls the response text file builder' do
        # Act
        service.call

        # Assert
        expect(response_text_file_builder_spy).to have_received(:call)
      end

      it 'calls the response pdf file builder' do
        # Act
        service.call

        # Assert
        expect(response_pdf_file_builder_spy).to have_received(:call)
      end

      it 'calls the response rtf file builder' do
        # Act
        service.call

        # Assert
        expect(response_rtf_file_builder_spy).to have_received(:call)
      end

      it 'has the correct default builder for the pdf file' do
        # Arrange - Setup a spy on the expected class - and stub its constant
        expected_class = class_spy('::EtAtosExport::ClaimFileBuilder::BuildResponsePdfFile').as_stubbed_const
        service = described_class.new response

        # Act
        service.call

        # Assert
        expect(expected_class).to have_received(:call)
      end

      it 'has the correct default builder for the rtf file' do
        # Arrange - Setup a spy on the expected class - and stub its constant
        class_spy('::EtAtosExport::ClaimFileBuilder::BuildResponseTextFile').as_stubbed_const
        class_spy('::EtAtosExport::ClaimFileBuilder::BuildResponsePdfFile').as_stubbed_const
        expected_class = class_spy('::EtAtosExport::ClaimFileBuilder::BuildResponseRtfFile').as_stubbed_const
        service = described_class.new response

        # Act
        service.call

        # Assert
        expect(expected_class).to have_received(:call)
      end
    end
  end
end
