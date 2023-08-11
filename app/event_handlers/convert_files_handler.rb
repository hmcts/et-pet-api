class ConvertFilesHandler
  def handle(resource, config: Rails.configuration, convertor: Libreconv)
    @resource = resource
    @config = config
    @convertor = convertor
    handle_files
  end

  private

  attr_reader :resource, :config, :convertor

  def handle_files
    handle_claim_files if resource.is_a?(Claim)
    handle_response_files if resource.is_a?(Response)
  end

  def handle_claim_files
    file = resource.claim_details_input_file
    if file_to_be_converted?(file)
      convert_file(file, new_filename: claim_details_file_name)
    else
      copy_claim_details_file
    end
  end

  def handle_response_files
    file = resource.additional_information_file
    return unless file.present? && file_to_be_converted?(file)

    convert_file(file, new_filename: 'additional_information.pdf')
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
    return if output_file_present?(filename: filename)

    convertor.convert(input_file.path, output_file.path)
    resource.uploaded_files.system_file_scope.create(filename: filename, file: { filename: filename, io: output_file, content_type: 'application/pdf' })
  end

  def claim_details_file_name(extension = :pdf)
    claimant = resource.primary_claimant
    "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.#{extension}"
  end

  def copy_claim_details_file
    file = resource.claim_details_input_file
    filename = claim_details_file_name(:rtf)
    return if file.nil? || output_file_present?(filename: filename)

    resource.uploaded_files.system_file_scope.create filename: filename, file: file.file.blob, checksum: file.checksum
  end

  def output_file_present?(filename:)
    resource.uploaded_files.system_file_scope.any? { |u| u.filename == filename }
  end

end
