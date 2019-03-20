module EtAtosExport
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
                                               tempfile: render_to_file(object: claim),
                                               type: 'text/plain'
      end

      def self.render(claim)
        ApplicationController.render "et_atos_export/file_builders/export_claimants.txt.erb", locals: {
          claim: claim, primary_claimant: claim.primary_claimant,
          secondary_claimants: claim.secondary_claimants.includes(:address),
          primary_respondent: claim.primary_respondent
        }
      end

      private_class_method :raw_claimants_text_file, :render
    end
  end
end
