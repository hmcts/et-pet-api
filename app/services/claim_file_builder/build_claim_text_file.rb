module ClaimFileBuilder
  module BuildClaimTextFile
    include ClaimFilename
    def self.call(claim)
      filename = filename_for(claim: claim, prefix: 'et1', extension: 'txt')
      claim.uploaded_files.build filename: filename,
                                 file: raw_text_file(filename, claim: claim)
    end

    def self.raw_text_file(filename, claim:)
      tempfile = Tempfile.new.tap do |file|
        file.write render(claim)
        file.rewind
      end
      ActionDispatch::Http::UploadedFile.new filename: filename, tempfile: tempfile, type: 'text/xml'
    end

    def self.render(claim)
      ApplicationController.render "file_builders/export.txt.erb", locals: {
        claim: claim, primary_claimant: claim.claimants.first,
        primary_respondent: claim.respondents.first,
        primary_representative: claim.representatives.first,
        additional_respondents: claim.respondents[1..-1]
      }
    end

    private_class_method :raw_text_file, :render
  end
end
