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
        ApplicationController.render "et_atos_export/file_builders/export.txt.erb", locals: {
          claim: claim, primary_claimant: claim.primary_claimant,
          primary_respondent: claim.primary_respondent,
          primary_representative: claim.primary_representative,
          additional_respondents: claim.secondary_respondents.includes(:address)
        }
      end

      private_class_method :raw_text_file, :render
    end
  end
end
