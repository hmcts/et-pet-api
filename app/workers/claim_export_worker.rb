require 'zip'
# Currently exports all claims that are waiting to be exported to a directory and zips them up.
# Depending on performance,this may get split into multiple workers to do stuff in parallel
class ClaimExportWorker
  include Sidekiq::Worker

  def initialize(claims_to_export: ClaimExport.includes(:claim),
    claim_export_service: ClaimExportService, exported_file: ExportedFile)
    self.claims_to_export = claims_to_export
    self.claim_export_service = claim_export_service
    self.exported_file = exported_file
  end

  def perform(*)
    Dir.mktmpdir do |dir|
      export_claims to: dir
      zip_files from: dir, to: zip_filename
      persist_zip_file
    end
  ensure
    remove_zip_if_exists
  end

  private

  attr_accessor :claims_to_export, :claim_export_service, :exported_file

  def zip_filename
    @zip_filename ||= File.join(Dir.mktmpdir, "ET_Fees_#{Time.zone.now.strftime('%d%m%y%H%M%S')}.zip")
  end

  def export_claims(to:)
    claims_to_export.each do |claim_export|
      claim_export_service.new(claim_export.claim).export_pdf
      export_pdf_file(claim: claim_export.claim, to: to)
    end
  end

  def export_pdf_file(claim:, to:)
    stored_file = claim_export_service.new(claim).export_pdf
    primary_claimant = claim.primary_claimant
    pdf_fn = "#{claim.reference}_ET1_#{primary_claimant.first_name.tr(' ', '_')}_#{primary_claimant.last_name}.pdf"
    stored_file.download_blob_to File.join(to, pdf_fn)
  end

  def zip_files(from:, to:)
    input_filenames = Dir.glob(File.join(from, '*'))
    Zip::File.open(to, Zip::File::CREATE) do |zipfile|
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
