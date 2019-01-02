require 'rspec/matchers'
require 'pdf-forms'
module EtApi
  module Test
    module FileObjects
      # A base class for all pdf files
      class BasePdfFile < Base # rubocop:disable Metrics/ClassLength
        include EtApi::Test::I18n
        include ::RSpec::Matchers

        def initalize(tempfile)
          self.tempfile = tempfile
        end

        private

        attr_accessor :tempfile

        def field_values
          @field_values ||= form.fields.inject({}) do |acc, field|
            if field.type == "Button" && field.options.present?
              acc[field.name] = field.options.include?(field.value) ? unescape(field.value) : nil
            else
              acc[field.name] = unescape(field.value)
            end
            acc
          end
        end

        def form
          @form ||= PdfForms.new('pdftk').read(tempfile.path)
        end

        def validate_fields(section:, errors:, indent:)
          aggregate_failures "Match pdf contents to input data" do
            yield
          end
          true
        rescue RSpec::Expectations::ExpectationNotMetError => err
          errors << "Invalid '#{section.to_s.humanize}' section in pdf"
          errors.concat(err.message.lines.map { |l| "#{'  ' * indent}#{l.gsub(/\n\z/, '')}" })
          false
        end

        def unescape(val)
          return val if val.nil?
          CGI.unescape_html(val)
        end
      end
    end
  end
end
