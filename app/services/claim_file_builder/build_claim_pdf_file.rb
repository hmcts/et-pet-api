module ClaimFileBuilder
  class BuildClaimPdfFile # rubocop:disable Metrics/ClassLength
    include PdfBuilder

    def self.call(claim, template_reference: 'et1-v1-en')
      new(claim, template_reference: template_reference).call
    end

    def initialize(claim, template_reference:, template_dir: Rails.root.join('vendor', 'assets', 'pdf_forms'))
      self.claim = claim
      self.template_dir = template_dir
      self.template_reference = template_reference
      self.yaml_file = File.join(template_dir, "#{template_reference}.yml")
    end

    def call
      filename = 'et1_atos_export.pdf'
      claim.uploaded_files.build filename: filename,
                                    file: blob_for_pdf_file(filename)
    end

    private

    attr_accessor :claim, :template_dir, :template_reference, :yaml_file

    def yaml_data
      @yaml_data ||= YAML.load_file(yaml_file).with_indifferent_access
    end

    def blob_for_pdf_file(filename)
      ActiveStorage::Blob.new.tap do |blob|
        blob.filename = filename
        blob.content_type = 'application/pdf'
        blob.metadata = nil
        blob.key = pre_allocated_key
        blob.upload render_to_file
      end
    end

    def pre_allocated_key
      claim.pre_allocated_file_keys.where(filename: 'et1_atos_export.pdf').first.try(:key)
    end

    def render_to_file
      tempfile = Tempfile.new
      template_path = File.join(template_dir, "#{template_reference}.pdf")
      fill_in_pdf_form(template_path: template_path, to: tempfile.path, data: pdf_fields)
      tempfile
    end

    def pdf_fields
      result = {}
      apply_header_pdf_fields(result)
      result
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

    def apply_header_pdf_fields(result)
      #apply_field result, response.case_number, :header, :case_number
    end
  end
end
