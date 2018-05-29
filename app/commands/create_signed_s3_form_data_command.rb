class CreateSignedS3FormDataCommand < BaseCommand
  def apply(root_object)
    root_object.merge!(input_data)
  end
end
