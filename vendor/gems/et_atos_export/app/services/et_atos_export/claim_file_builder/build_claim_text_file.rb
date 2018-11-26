module EtAtosExport
  module ClaimFileBuilder
    module BuildClaimTextFile
      include ClaimFilename
      include RenderToFile
      def self.call(claim)
        filename = filename_for(claim: claim, prefix: 'et1', extension: 'txt')
        claim.uploaded_files.build filename: filename,
                                   file: raw_text_file(filename, claim: claim)
      end

      def self.raw_text_file(filename, claim:)
        ActionDispatch::Http::UploadedFile.new filename: filename,
                                               tempfile: render_to_file(object: claim),
                                               type: 'text/plain'
      end

      def self.render(claim)
        ApplicationController.render "file_builders/export.txt.erb", locals: {
          claim: claim, primary_claimant: claim.primary_claimant,
          primary_respondent: claim.respondents.first,
          primary_representative: claim.representatives.first,
          additional_respondents: claim.respondents[1..-1]
        }
      end

      private_class_method :raw_text_file, :render
    end
  end
end
