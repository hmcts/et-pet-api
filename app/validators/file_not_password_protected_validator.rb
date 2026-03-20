# frozen_string_literal: true

require 'pdf-reader'
require 'shellwords'

class FileNotPasswordProtectedValidator < ActiveModel::EachValidator
  PASSWORD_PROTECTABLE_EXTENSIONS = %w[pdf doc docx xls xlsx ppt pptx].freeze
  LEGACY_OFFICE_EXTENSIONS = %w[doc xls ppt].freeze
  OOXML_EXTENSIONS = %w[docx xlsx pptx].freeze

  def validate_each(record, attribute, value)
    direct_uploaded_file = DirectUploadedFile.find_by_key(value)
    return if direct_uploaded_file.nil?

    extension = File.extname(direct_uploaded_file.filename.to_s).delete('.').downcase
    return unless PASSWORD_PROTECTABLE_EXTENSIONS.include?(extension)

    direct_uploaded_file.file.blob.open do |downloaded_file|
      return unless password_protected?(downloaded_file.path, extension)

      record.errors.add(attribute, :password_protected, **extra_error_details(record))
    end
  rescue StandardError => e
    Rails.logger.tagged("FileNotPasswordProtectedValidator") do |logger|
      logger.info("Unable to determine password protection for file #{value}: #{e.class}: #{e.message}")
    end
  end

  private

  def password_protected?(path, extension)
    case extension
    when 'pdf'
      pdf_password_protected?(path)
    when *LEGACY_OFFICE_EXTENSIONS
      legacy_office_password_protected?(path, extension)
    when *OOXML_EXTENSIONS
      ooxml_password_protected?(path)
    else
      false
    end
  end

  def pdf_password_protected?(path)
    PDF::Reader.new(path)
    false
  rescue PDF::Reader::EncryptedPDFError
    true
  end

  def legacy_office_password_protected?(path, extension)
    return true if file_description(path).include?('Security: 1')
    return powerpoint_password_protected?(path) if extension == 'ppt'

    false
  end

  def ooxml_password_protected?(path)
    mime_type(path) == 'application/encrypted' || file_description(path).include?('CDFV2 Encrypted')
  end

  def powerpoint_password_protected?(path)
    !`strings -a #{Shellwords.escape(path)}`.include?('[Content_Types].xmlPK')
  end

  def mime_type(path)
    `file --b --mime-type #{Shellwords.escape(path)}`.strip
  end

  def file_description(path)
    `file --b #{Shellwords.escape(path)}`.strip
  end

  def extra_error_details(record)
    return {} unless record.is_a?(BaseCommand)

    {
      uuid: record.uuid,
      command: record.command_name
    }
  end
end
