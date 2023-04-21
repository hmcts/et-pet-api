require 'rspec/matchers'
require 'pdf-forms'
require_relative '../base_pdf_section'
module EtApi
  module Test
    module FileObjects
      # Represents the ET3 PDF file and provides assistance in validating its contents
      module Et3PdfFileSection
        class Base < ::EtApi::Test::FileObjects::BasePdfSection

        end
      end
    end
  end
end
