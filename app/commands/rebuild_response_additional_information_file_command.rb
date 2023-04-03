class RebuildResponseAdditionalInformationFileCommand < BuildResponseAdditionalInformationFileCommand
  def apply(root_object, **_args)
    delete_additional_info_file_if_faulty(root_object)
    return if additional_info_file_exists?(root_object)

    super
  end

  private

  def additional_info_file_exists?(root_object)
    root_object.uploaded_files.et3_input_additional_info.first.present?
  end

  def delete_additional_info_file_if_faulty(root_object)
    uploaded_file = root_object.uploaded_files.et3_input_additional_info.first
    return if uploaded_file.nil?

    service = uploaded_file.file.attachment&.service
    delete_additional_info_file(root_object) && return if service.nil? || !service.exist?(uploaded_file.file.key)

    true
  end

  def delete_additional_info_file(root_object)
    uploaded_file = root_object.uploaded_files.et3_input_additional_info.first
    string_io = StringIO.new("This file is uploaded only to allow the deletion of the blob to work without error")
    uploaded_file.file.attachment&.blob&.upload(string_io, identify: false)
    root_object.uploaded_files.et3_input_additional_info.destroy_all
  end
end
