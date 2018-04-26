module ClaimFileBuilder
  module BuildClaimTextFile
    def self.call(claim)
      claimant = claim.claimants.first
      filename = "et1_#{claimant.first_name.tr(' ', '_')}_#{claimant.last_name}.txt"
      claim.uploaded_files.build filename: filename,
                                 file: raw_text_file(filename, claim: claim)
    end

    def self.raw_text_file(filename, claim:)
      tempfile = Tempfile.new.tap do |file|
        file.write ApplicationController.render "file_builders/export.txt.erb", locals: {
          claim: claim, primary_claimant: claim.claimants.first,
          primary_respondent: claim.respondents.first,
          primary_representative: claim.representatives.first,
          additional_respondents: claim.respondents[1..-1]
        }
        file.rewind
      end
      ActionDispatch::Http::UploadedFile.new filename: filename, tempfile: tempfile, type: 'text/xml'
    end

    private_class_method :raw_text_file
  end
end
