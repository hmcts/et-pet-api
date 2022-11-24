class FileContentTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.attached?

    extension = File.extname(value.filename.to_s)[1..]
    mime_type_by_ext = Mime::Type.lookup_by_extension(extension)
    mime_type_stored = Mime::Type.lookup(value.content_type)
    return if mime_type_by_ext == mime_type_stored

    record.errors.add(attribute, :mismatching_file_content_type, expected: extension)
  end
end
