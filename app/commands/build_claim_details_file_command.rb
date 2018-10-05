class BuildClaimDetailsFileCommand < BaseCommand
  def apply(root_object)
    root_object.uploaded_files.build merged_input_data
  end

  private

  def merged_input_data
    input_data.merge import_file_url: input_data.delete(:data_url), import_from_key: input_data.delete(:data_from_key)
  end
end
