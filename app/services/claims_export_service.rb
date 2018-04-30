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
    export_pdf_file(claim: claim, to: to)
    export_xml_file(claim: claim, to: to)
    export_text_file(claim: claim, to: to)
    export_claimants_text_file(claim: claim, to: to) if claim.claimants.count > 1
    export_claimants_csv_file(claim: claim, to: to) if claim_has_claimants_csv?(claim: claim)
  end

  def mark_claims_as_exported
    # Destroy each individually to
    claims_to_export.where(id: claim_exports.map(&:id)).delete_all
  end

  def export_pdf_file(claim:, to:)
    stored_file = claim_export_service.new(claim).export_pdf
    primary_claimant = claim.primary_claimant
    pdf_fn = "#{claim.reference}_ET1_#{primary_claimant.first_name.tr(' ', '_')}_#{primary_claimant.last_name}.pdf"
    stored_file.download_blob_to File.join(to, pdf_fn)
  end

  def export_xml_file(claim:, to:)
    stored_file = claim_export_service.new(claim).export_xml
    primary_claimant = claim.primary_claimant
    xml_fn = "#{claim.reference}_ET1_#{primary_claimant.first_name.tr(' ', '_')}_#{primary_claimant.last_name}.xml"
    stored_file.download_blob_to File.join(to, xml_fn)
  end

  def export_text_file(claim:, to:)
    stored_file = claim_export_service.new(claim).export_txt
    primary_claimant = claim.primary_claimant
    txt_fn = "#{claim.reference}_ET1_#{primary_claimant.first_name.tr(' ', '_')}_#{primary_claimant.last_name}.txt"
    stored_file.download_blob_to File.join(to, txt_fn)
  end

  def export_claimants_text_file(claim:, to:)
    stored_file = claim_export_service.new(claim).export_claimants_txt
    primary_claimant = claim.primary_claimant
    txt_fn = "#{claim.reference}_ET1a_#{primary_claimant.first_name.tr(' ', '_')}_#{primary_claimant.last_name}.txt"
    stored_file.download_blob_to File.join(to, txt_fn)
  end

  def export_claimants_csv_file(claim:, to:)
    stored_file = claim_export_service.new(claim).export_claimants_csv
    primary_claimant = claim.primary_claimant
    csv_fn = "#{claim.reference}_ET1a_#{primary_claimant.first_name.tr(' ', '_')}_#{primary_claimant.last_name}.csv"
    stored_file.download_blob_to File.join(to, csv_fn)
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

  def claim_has_claimants_csv?(claim:)
    claim.uploaded_files.any? { |f| f.filename.starts_with?('et1a') && f.filename.ends_with?('.csv') }
  end
end
