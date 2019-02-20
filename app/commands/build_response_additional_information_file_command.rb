class BuildResponseAdditionalInformationFileCommand < BaseCommand
  attribute :filename, :string
  attribute :checksum, :string
  attribute :data_from_key, :string
  attribute :data_url, :string

  def apply(root_object, **_args)
    root_object.uploaded_files.build merged_input_data
  end

  private

  def merged_input_data
    input_data = attributes.to_h.symbolize_keys
    input_data.merge import_file_url: input_data.delete(:data_url), import_from_key: input_data.delete(:data_from_key)
  end
end
