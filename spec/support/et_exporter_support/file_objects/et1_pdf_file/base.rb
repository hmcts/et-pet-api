require 'rspec/matchers'
require 'pdf-forms'
require_relative '../base_pdf_section'
module EtApi
  module Test
    module FileObjects
      # Represents the ET3 PDF file and provides assistance in validating its contents
      module Et1PdfFileSection
        class Base < ::EtApi::Test::FileObjects::BasePdfSection # rubocop:disable Metrics/ClassName

          private

          # Postcodes in the pdf have no spaces in them, but the inputs might.  Also, the pdf
          # will only ever remember the first 7 characters
          def formatted_post_code(val, optional: false)
            return nil if val.nil? && optional
            match = val.match(/\A\s*(\S+)\s*(\d\w\w)\s*\z/)
            return val.slice(0,7) unless match
            spaces = 4 - match[1].length
            val = "#{match[1]}#{' ' * spaces}#{match[2]}"
            val.slice(0,7)
          end
        end
      end
    end
  end
end
