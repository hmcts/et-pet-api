class ConvertFilesHandler
  def handle(resource)
    @resource = resource
    handle_files
  end

  private

  attr_reader :resource

  def handle_files
    handle_claim_files if resource.is_a?(Claim)
  end

  def handle_claim_files
    copy_claim_details_file
  end

  def claim_details_file_name(extension = :rtf)
    claimant = resource.primary_claimant
    "et1_attachment_#{claimant[:first_name].tr(' ', '_')}_#{claimant[:last_name]}.#{extension}"
  end

  def copy_claim_details_file
    file = resource.claim_details_input_file
    filename = claim_details_file_name
    return if file.nil? || output_file_present?(filename: filename)

    resource.uploaded_files.system_file_scope.create filename: filename, file: file.file.blob, checksum: file.checksum
  end

  def output_file_present?(filename:)
    resource.uploaded_files.system_file_scope.any? { |u| u.filename == filename }
  end
end
