# Produces the claimants text file for a claim
#
# Whilst this is a legacy file for the old ATOS system, it is often used by
# office staff to check the claimants details for multiple claimants.
class ClaimClaimantsFileHandler
  def handle(claim)
    @claim = claim
    claim.uploaded_files.system_file_scope.build filename: filename,
                                                 file: raw_claimants_text_file
  end

  private

  attr_reader :claim

  def filename
    return @filename if defined?(@filename)

    claimant = claim.primary_claimant
    @filename = "et1a_#{claimant.first_name.tr(' ', '_')}_#{claimant.last_name}.txt"
  end

  def render_to_file
    Tempfile.new(encoding: 'windows-1252', invalid: :replace, undef: :replace, replace: '').tap do |file|
      file.write with_windows_lf(render)
      file.rewind
    end
  end

  def with_windows_lf(string)
    string.encode(crlf_newline: true)
  end

  def raw_claimants_text_file
    ActionDispatch::Http::UploadedFile.new filename: filename,
                                           tempfile: render_to_file,
                                           type: 'text/plain'
  end

  def render
    ApplicationController.render "file_builders/claim_claimants",
                                 locals: {
                                   claim: claim, primary_claimant: claim.primary_claimant,
                                   secondary_claimants: claim.secondary_claimants.includes(:address),
                                   primary_respondent: claim.primary_respondent
                                 }, formats: [:text]
  end

end
