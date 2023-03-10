class ConvertFilesHandler
  def handle(resource, config: Rails.configuration, convertor: Libreconv)
    @resource = resource
    @config = config
    @convertor = convertor
    handle_rtf_files
  end

  private

  attr_reader :resource, :config, :convertor

  def handle_rtf_files
    handle_claim_rtf_files
    handle_response_rtf_files
  end

  def handle_claim_rtf_files
    file = resource.rtf_file
    if file_to_be_converted?(file)
      convert_file(file, new_filename: claim_details_file_name)
    else
      copy_claim_rtf_file
    end

  end

  def handle_response_rtf_files

  end

  def file_to_be_converted?(file)
    return false unless config.file_conversions.enabled && file.present?

    config.file_conversions.allowed_types.any? do |type|
      Mime::Type.lookup(type).match?(file.content_type)
    end
  end

  def convert_file(file, new_filename: nil)
    input_file = Tempfile.new(file.filename)
    file.download_blob_to(input_file.path)
    filename = new_filename || File.basename(file.filename)
    output_file = Tempfile.new(filename)
    convertor.convert(input_file.path, output_file.path)
    resource.uploaded_files.system_file_scope.create(filename: filename, file: { filename: filename, io: output_file, content_type: 'application/pdf' })
  end

  def claim_details_file_name(extension = :pdf)
    claimant = resource.primary_claimant
    "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.#{extension}"
  end

  def copy_claim_rtf_file
    file = resource.rtf_file
    filename = claim_details_file_name(:rtf)
    return if file.nil? || output_file_present?(filename: filename)

    resource.uploaded_files.system_file_scope.create filename: filename, file: file.file.blob, checksum: file.checksum
  end

  def output_file_present?(filename:)
    resource.uploaded_files.system_file_scope.any? { |u| u.filename == filename }
  end

end
