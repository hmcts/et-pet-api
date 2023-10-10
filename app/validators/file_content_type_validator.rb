class FileContentTypeValidator < ActiveModel::EachValidator
  ALLOWED_FILE_EXTENSIONS = %w[rtf csv].freeze
  ALLOWED_CONTENT_TYPES = ['text/rtf', 'application/rtf', 'application/msword', 'text/csv'].freeze

  def validate_each(record, attribute, value)
    return unless value.attached?

    extension = File.extname(value.filename.to_s)[1..]
    mime_type_by_ext = Mime::Type.lookup_by_extension(extension)
    mime_type_stored = Mime::Type.lookup(value.content_type)

    error_messages = []

    # Check extension
    unless ALLOWED_FILE_EXTENSIONS.include?(extension)
      error_messages << I18n.t('activerecord.errors.models.direct_uploaded_file.attributes.file.invalid_file_extension', content_type: value.content_type)
    end

    # Check content type
    unless ALLOWED_CONTENT_TYPES.include?(value.content_type)
      error_messages << I18n.t('activerecord.errors.models.direct_uploaded_file.attributes.file.invalid_file_content_type', content_type: value.content_type)
    end

    # Check for mismatching content type and extension
    if mime_type_by_ext != mime_type_stored
      error_messages << I18n.t('activerecord.errors.models.direct_uploaded_file.attributes.file.mismatching_file_content_type', expected: extension)
    end

    # Add the combined error message to the record
    record.errors.add(attribute, :invalid_file, message: error_messages.join(', ')) unless error_messages.empty?
  end
end
