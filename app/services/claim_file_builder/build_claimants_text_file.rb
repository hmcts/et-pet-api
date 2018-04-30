module ClaimFileBuilder
  module BuildClaimantsTextFile
    include ClaimFilename
    include RenderToFile
    def self.call(claim)
      filename = filename_for(claim: claim, prefix: 'et1a', extension: 'txt')
      claim.uploaded_files.build filename: filename,
                                 file: raw_claimants_text_file(filename, claim: claim)
    end

    def self.raw_claimants_text_file(filename, claim:)
      ActionDispatch::Http::UploadedFile.new filename: filename,
                                             tempfile: render_to_file(claim: claim),
                                             type: 'text/xml'
    end

    def self.render(claim)
      ApplicationController.render "file_builders/export_claimants.txt.erb", locals: {
        claim: claim, primary_claimant: claim.claimants.first,
        secondary_claimants: claim.claimants[1..-1],
        primary_respondent: claim.respondents.first
      }
    end

    private_class_method :raw_claimants_text_file, :render
  end
end
