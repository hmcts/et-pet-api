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

  def apply_selected_value_for(result, field_def, field_value)
    if field_def[:field_name].is_a?(Array)
      results = selected_value_for(field_def, field_value)
      field_def[:field_name].each_with_index do |field_name, idx|
        result[field_name] = results[idx]
      end
    else
      result[field_def[:field_name]] = selected_value_for(field_def, field_value)
    end
  end

  def selected_value_for(field_def, field_value)
    if field_value.nil?
      field_def[:unselected_value]
    else
      raise "Value of #{field_value} is not valid for the field definition #{field_def[:field_name]}" unless field_def[:select_values].key?(field_value)

      field_def[:select_values][field_value]
    end
  end
end
