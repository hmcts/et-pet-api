# frozen_string_literal: true

# This service takes a built response and produces all atos files required to be attached
#
module EtAtosExport
  class ResponseFileBuilderService
    def initialize(response,
      response_text_file_builder: ::EtAtosExport::ResponseFileBuilder::BuildResponseTextFile,
      response_rtf_file_builder: ::EtAtosExport::ResponseFileBuilder::BuildResponseRtfFile)
      self.response = response
      self.response_text_file_builder = response_text_file_builder
      self.response_rtf_file_builder = response_rtf_file_builder
    end

    def call
      add_file :response_rtf_file, to: response
      add_file :response_text_file, to: response
    end

    private

    def add_file(builder_type, to:)
      builder = send(:"#{builder_type}_builder")
      builder.call(to)
    end

    attr_accessor :response, :response_text_file_builder, :response_rtf_file_builder
  end
end
