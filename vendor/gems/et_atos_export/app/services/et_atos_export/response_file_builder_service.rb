# frozen_string_literal: true

# This service takes a built response and produces all atos files required to be attached
#
module EtAtosExport
  class ResponseFileBuilderService
    def initialize(response, response_text_file_builder: ClaimFileBuilder::BuildResponseTextFile)
      self.response = response
      self.response_text_file_builder = response_text_file_builder
    end

    def call
      response_text_file_builder.call(response)
    end

    private

    attr_accessor :response, :response_text_file_builder
  end
end
