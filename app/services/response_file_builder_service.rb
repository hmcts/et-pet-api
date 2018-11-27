# frozen_string_literal: true

# This service takes a built response and produces all files required to be attached
#
class ResponseFileBuilderService
  def initialize(response, response_pdf_file_builder: ResponseFileBuilder::BuildResponsePdfFile)
    self.response = response
    self.response_pdf_file_builder = response_pdf_file_builder
  end

  def call
    response_pdf_file_builder.call(response)
  end

  private

  attr_accessor :response, :response_pdf_file_builder
end
