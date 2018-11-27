# frozen_string_literal: true

# This service takes a built response and produces all files required to be attached
#
class ResponseFileBuilderService
  def initialize(response,
    response_pdf_file_builder: ResponseFileBuilder::BuildResponsePdfFile,
    response_rtf_file_builder: ResponseFileBuilder::BuildResponseRtfFile)
    self.response = response
    self.response_pdf_file_builder = response_pdf_file_builder
    self.response_rtf_file_builder = response_rtf_file_builder
  end

  def call
    add_file :response_rtf_file, to: response
    add_file :response_pdf_file, to: response
  end

  private

  def add_file(builder_type, to:)
    builder = send(:"#{builder_type}_builder")
    builder.call(to)
  end

  attr_accessor :response, :response_pdf_file_builder, :response_rtf_file_builder
end
