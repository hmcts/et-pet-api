# frozen_string_literal: true
require 'zip'
# Exports all claims that have been marked for needing export
class ClaimsExportService

  def initialize(claims_to_export: ClaimExport.includes(:claim),
    claim_export_service: ClaimExportService, exported_file: ExportedFile)
    self.claims_to_export = claims_to_export
    self.claim_export_service = claim_export_service
    self.exported_file = exported_file
    self.claim_exports = []
  end

  # Exports everything and marks the claims as exported so they cannot be exported again
  def export
    Dir.mktmpdir do |dir|
      export_claims to: dir
      next if claim_exports.empty?
      zip_files from: dir
      persist_zip_file
      mark_claims_as_exported
    end
  ensure
    remove_zip_if_exists
  end

  private

  attr_accessor :claims_to_export, :claim_export_service, :exported_file, :claim_exports

  def zip_filename
    @zip_filename ||= File.join(Dir.mktmpdir, "ET_Fees_#{Time.zone.now.strftime('%d%m%y%H%M%S')}.zip")
  end

  def export_claims(to:)
    claims_to_export.each do |claim_export|
      claim_exports << claim_export
      export_files(claim_export.claim, to: to)
    end
  end

  def export_files(claim, to:)
    export_file(claim: claim, to: to, prefix: 'ET1', ext: :pdf, type: :pdf)
    export_file(claim: claim, to: to, prefix: 'ET1', ext: :xml, type: :xml)
    export_file(claim: claim, to: to, prefix: 'ET1', ext: :txt, type: :txt)
    export_file(claim: claim, to: to, prefix: 'ET1a', ext: :txt, type: :claimants_txt) if claim.claimants.count > 1
    export_file(claim: claim, to: to, prefix: 'ET1a', ext: :csv, type: :claimants_csv) if claim_has_csv?(claim: claim)
    export_file(claim: claim, to: to, prefix: 'ET1_Attachment', ext: :rtf, type: :rtf) if claim_has_rtf?(claim: claim)
  end

  def mark_claims_as_exported
    # Destroy each individually to
    claims_to_export.where(id: claim_exports.map(&:id)).delete_all
  end

  def export_file(claim:, to:, prefix:, ext:, type:)
    stored_file = claim_export_service.new(claim).send(:"export_#{type}")
    primary_claimant = claim.primary_claimant
    fn = "#{claim.reference}_#{prefix}_#{primary_claimant.first_name.tr(' ', '_')}_#{primary_claimant.last_name}.#{ext}"
    stored_file.download_blob_to File.join(to, fn)
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

  def claim_has_csv?(claim:)
    claim.uploaded_files.any? { |f| f.filename.starts_with?('et1a') && f.filename.ends_with?('.csv') }
  end

  def claim_has_rtf?(claim:)
    claim.uploaded_files.any? { |f| f.filename.starts_with?('et1_attachment') && f.filename.ends_with?('.rtf') }
  end
end
