class BuildPdfFileCommand < BaseCommand
  def apply(root_object)
    root_object.uploaded_files.build merged_inputs
  end

  private

  def merged_inputs
    input_data.merge import_file_url: input_data.delete(:data_url), import_from_key: input_data.delete(:data_from_key)
  end
end
