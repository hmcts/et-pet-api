# frozen_string_literal: true
require 'zip'
# Exports all claims that have been marked for needing export
class ExportService

  def initialize(exported_file: EtAtosFileTransfer::ExportedFile,
    claim_exporter: ::ExportServiceExporters::ClaimExporter,
    response_exporter: ::ExportServiceExporters::ResponseExporter)
    self.claim_exporter = claim_exporter.new
    self.response_exporter = response_exporter.new
    self.exported_file = exported_file
    self.exported_count = 0
  end

  # Exports everything and marks the claims as exported so they cannot be exported again
  def export
    Dir.mktmpdir do |dir|
      export_all to: dir
      next if exported_count.zero?
      zip_files from: dir
      persist_zip_file
      mark_all_as_exported
    end
  ensure
    remove_zip_if_exists
  end

  private

  attr_accessor :exported_file, :claim_exporter, :response_exporter, :exported_count

  def export_all(to:)
    claim_exporter.export to: to
    response_exporter.export to: to
    self.exported_count = claim_exporter.exported_count + response_exporter.exported_count
  end

  def mark_all_as_exported
    claim_exporter.mark_claims_as_exported
    response_exporter.mark_responses_as_exported
  end

  def zip_filename
    @zip_filename ||= File.join(Dir.mktmpdir, "ET_Fees_#{Time.zone.now.strftime('%d%m%y%H%M%S')}.zip")
  end

  def zip_files(from:)
    input_filenames = Dir.glob(File.join(from, '*'))
    ::Zip::File.open(zip_filename, ::Zip::File::CREATE) do |zipfile|
      input_filenames.each do |filename|
        zipfile.add(File.basename(filename), filename)
      end
    end
  end

  def remove_zip_if_exists
    return unless File.exist?(zip_filename)
    FileUtils.rm_rf(File.dirname(zip_filename))
  end

  def persist_zip_file
    filename = File.basename(zip_filename)
    File.open(zip_filename) do |file|
      file_attributes = { io: file, filename: filename, content_type: "application/zip" }
      exported_file.create!(file_attributes: file_attributes, filename: filename)
    end
  end
end
