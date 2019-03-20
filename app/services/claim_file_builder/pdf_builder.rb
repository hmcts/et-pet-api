module ClaimFileBuilder
  module PdfBuilder
    extend ActiveSupport::Concern

    def builder
      @builder ||= PdfForms.new('pdftk', utf8_fields: true)
    end

    private

    def fill_in_pdf_form(template_path:, data:, to:)
      builder.fill_form(template_path, to, data)
    end

    def apply_field(result, field_value, *path)
      field_def = yaml_data.dig(*path)
      raise "Field #{path} does not exist in the file #{yaml_file}" unless field_def
      return if field_def[:field_name] == false

      if field_def.key?(:select_values)
        apply_selected_value_for(result, field_def, field_value)
      else
        result[field_def[:field_name]] = field_value
      end
    end
  end
end
