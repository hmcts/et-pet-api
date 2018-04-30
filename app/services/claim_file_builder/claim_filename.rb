module ClaimFileBuilder
  module ClaimFilename
    extend ActiveSupport::Concern

    class_methods do
      def filename_for(claim:, extension: "txt", prefix: "et1")
        claimant = claim.claimants.first
        "#{prefix}_#{claimant.first_name.tr(' ', '_')}_#{claimant.last_name}.#{extension}"
      end
    end
  end
end
