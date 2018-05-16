require 'rails_helper'

RSpec.describe ResponseFileBuilderService do
  subject(:service) do
    described_class.new response,
      response_text_file_builder: response_text_file_builder_spy,
      response_pdf_file_builder: response_pdf_file_builder_spy

  end

  # Setup for all
  # Spies for the builders which return nothing
  let(:response_text_file_builder_spy) { class_spy('ClaimFileBuilder::BuildResponseTextFile') }
  let(:response_pdf_file_builder_spy) { class_spy('ClaimFileBuilder::BuildResponsePdfFile') }

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

    it 'has the correct default builder for the pdf file' do
      # Arrange - Setup a spy on the expected class - and stub its constant
      expected_class = class_spy('ClaimFileBuilder::BuildResponsePdfFile').as_stubbed_const
      service = described_class.new response

      # Act
      service.call

      # Assert
      expect(expected_class).to have_received(:call)
    end
  end
end
