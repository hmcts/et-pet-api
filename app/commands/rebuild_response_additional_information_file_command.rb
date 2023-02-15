class RebuildResponseAdditionalInformationFileCommand < BuildResponseAdditionalInformationFileCommand
  def apply(root_object, **_args)
    delete_rtf_file_if_faulty(root_object)
    return if rtf_file_exists?(root_object)

    super
  end

  private

  def rtf_file_exists?(root_object)
    root_object.uploaded_files.et3_input_rtf.first.present?
  end

  def delete_rtf_file_if_faulty(root_object)
    uploaded_file = root_object.uploaded_files.et3_input_rtf.first
    return if uploaded_file.nil?

    service = uploaded_file.file.attachment&.service
    delete_rtf_file(root_object) && return if service.nil? || !service.exist?(uploaded_file.file.key)

    true
  end

  def delete_rtf_file(root_object)
    uploaded_file = root_object.uploaded_files.et3_input_rtf.first
    string_io = StringIO.new("This file is uploaded only to allow the deletion of the blob to work without error")
    uploaded_file.file.attachment&.blob&.upload(string_io, identify: false)
    root_object.uploaded_files.et3_input_rtf.destroy_all
  end
end
