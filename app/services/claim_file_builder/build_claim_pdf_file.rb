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
      apply_your_details_fields(result)
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

    def apply_your_details_fields(result)
      primary_claimant = claim.primary_claimant
      pca = primary_claimant.address
      apply_field result, primary_claimant.title, :your_details, :title
      apply_field result, primary_claimant.first_name, :your_details, :first_name
      apply_field result, primary_claimant.last_name, :your_details, :last_name
      apply_field result, primary_claimant.gender, :your_details, :gender
      apply_field result, pca.building, :your_details, :building
      apply_field result, pca.street, :your_details, :street
      apply_field result, pca.locality, :your_details, :locality
      apply_field result, pca.county, :your_details, :county
      apply_field result, post_code_for(pca.post_code), :your_details, :post_code
      apply_field result, primary_claimant.mobile_number, :your_details, :alternative_telephone_number
      apply_field result, primary_claimant.contact_preference, :your_details, :correspondence
      apply_field result, primary_claimant.date_of_birth.day, :your_details, :dob_day
      apply_field result, primary_claimant.date_of_birth.month, :your_details, :dob_month
      apply_field result, primary_claimant.date_of_birth.year, :your_details, :dob_year
      apply_field result, primary_claimant.email_address, :your_details, :email_address
      apply_field result, primary_claimant.address_telephone_number, :your_details, :telephone_number
    end

    def post_code_for(val, optional: false)
      return nil if val.nil? && optional
      match = val.match(/\A\s*(\S+)\s*(\d\w\w)\s*\z/)
      return val.slice(0,7) unless match
      spaces = 4 - match[1].length
      val = "#{match[1]}#{' ' * spaces}#{match[2]}"
      val.slice(0,7)
    end

  end
end
