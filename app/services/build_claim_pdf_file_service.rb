class BuildClaimPdfFileService
  include PdfBuilder::Base
  include PdfBuilder::MultiTemplate
  include PdfBuilder::Rendering
  include PdfBuilder::PreAllocation

  def self.call(source, template_reference: 'et1-v3-en', time_zone: 'London', **)
    new(source, template_reference: template_reference, time_zone: time_zone).call
  end

  def call
    claimant = source.primary_claimant
    citizen_filename = "et1_#{scrubber claimant.first_name}_#{scrubber claimant.last_name}.pdf"
    office_filename = "et1_#{scrubber claimant.first_name}_#{scrubber claimant.last_name}_trimmed.pdf"

    blobs_for_pdf_files(citizen_filename, office_filename).each do |blob|
      source.uploaded_files.system_file_scope.build filename: blob.filename, file: blob
    end
  end

  private

  def scrubber(text)
    text.gsub(/\s/, '_').gsub(/\W/, '').downcase
  end

  def render_to_files
    et1 = BuildClaimEt1PdfFileService.call(source, template_reference: template_reference, time_zone: time_zone)

    if source.secondary_claimants.present?
      et1a = BuildClaimEt1aPdfFileService.call(source, template_reference: template_reference.gsub(/et1-/, 'et1a-'), time_zone: time_zone)
    end

    path_specs = [{ et1.output_file.path => ['1-12'] }]
    path_specs << { et1a.output_file.path => ['13-15'] } if et1a

    [
      Tempfile.new.tap { |file| builder.cat(*path_specs, { et1.output_file.path => ['13-15'] }, file.path) },
      Tempfile.new.tap { |file| builder.cat(*path_specs, file.path) }
    ]
  end

  def blobs_for_pdf_files(citizen_filename, office_filename)
    files = render_to_files
    [::ActiveStorage::Blob.find_or_initialize_by(key: pre_allocated_key(citizen_filename)).tap do |blob|
      blob.filename = citizen_filename
      blob.content_type = 'application/pdf'
      blob.metadata[:uploaded] = true
      blob.service_name = Rails.configuration.active_storage.service
      blob.upload files.first
    end,
     ::ActiveStorage::Blob.new.tap do |blob|
       blob.filename = office_filename
       blob.content_type = 'application/pdf'
       blob.metadata = nil
       blob.service_name = Rails.configuration.active_storage.service
       blob.upload files.last
     end]
  end

  attr_reader :source, :template_reference, :time_zone
end
