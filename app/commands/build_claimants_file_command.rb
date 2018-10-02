class BuildClaimantsFileCommand < BaseCommand
  def apply(root_object)
    root_object.uploaded_files.build(input_data.merge(import_file_url: input_data.delete(:data_url), import_from_key: input_data.delete(:data_from_key)))
  end
end
