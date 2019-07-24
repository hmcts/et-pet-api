require_relative '../../spec/support/messaging'
require_relative '../../spec/support/landing_folder_support/file_objects/et1_pdf_file'
module Cli
  class PdfCommand < Rails::Command::Base
    namespace 'pdf'
    desc 'parse', 'Parses the pdf either providing the raw format or normalised format (same as test suite)'
    method_option :format, type: :string, default: 'raw'
    method_option :template, type: :string, default: 'et1-v1-en'
    def parse(filename)
      file = File.open(filename, 'r')
      o = EtApi::Test::FileObjects::Et1PdfFile.new(file, template: options[:template], lookup_root: 'claim_pdf_fields')
      formatter = "::Cli::PdfCommand::#{options[:format].camelize}Formatter".safe_constantize
      raise "format must be 'raw' or 'normalised'" if formatter.nil?
      formatter.call(o)
    ensure
      file.close
    end

    class RawFormatter
      def self.call(file_object)
        fields = file_object.send(:form).fields.inject({}) do |acc, field|
          acc[field.name] = field.value
          acc
        end
        puts JSON.pretty_generate(fields)
      end
    end

    class NormalisedFormatter
      def self.call(file_object)
        fields = file_object.public_methods.select {|m| m.to_s.end_with?('_section')}.inject({}) do |acc, section|
          acc[section.to_sym] = file_object.send(section).send(:mapped_field_values)
          acc
        end
        puts JSON.pretty_generate(fields)
      end
    end
  end
end
