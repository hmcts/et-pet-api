module ClaimFileBuilder
  module BuildClaimantsTextFile
    def self.call(claim)
      claimant = claim.claimants.first
      filename = "et1a_#{claimant.first_name.tr(' ', '_')}_#{claimant.last_name}.txt"
      claim.uploaded_files.build filename: filename,
                                 file: raw_claimants_text_file(filename, claim: claim)
    end

    def self.raw_claimants_text_file(filename, claim:)
      tempfile = Tempfile.new.tap do |file|
        file.write ApplicationController.render "file_builders/export_claimants.txt.erb", locals: {
          claim: claim, primary_claimant: claim.claimants.first,
          secondary_claimants: claim.claimants[1..-1],
          primary_respondent: claim.respondents.first
        }
        file.rewind
      end
      ActionDispatch::Http::UploadedFile.new filename: filename, tempfile: tempfile, type: 'text/xml'
    end

    private_class_method :raw_claimants_text_file
  end
end
