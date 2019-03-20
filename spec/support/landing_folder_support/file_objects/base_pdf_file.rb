require 'rspec/matchers'
require 'pdf-forms'
module EtApi
  module Test
    module FileObjects
      # A base class for all pdf files
      class BasePdfFile < Base
        include EtApi::Test::I18n
        include ::RSpec::Matchers

        def initialize(tempfile, form = nil)
          super(tempfile)
          self.form = form || PdfForms.new('pdftk', utf8_fields: true).read(tempfile.path)
        end

        private

        attr_accessor :form

        def field_values
          @field_values ||= form.fields.inject({}) do |acc, field|
            acc[field.name] = if field.type == "Button" && field.options.present?
                                field.options.include?(field.value) ? unescape(field.value) : nil
                              else
                                unescape(field.value)
                              end
            acc
          end
        end

        def unescape(val)
          return val if val.nil?

          CGI.unescape_html(val)
        end
      end
    end
  end
end
