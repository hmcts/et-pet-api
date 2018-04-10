# frozen_string_literal: true

module Api
  module V1
    class ClaimsController < ::ActionController::API
      before_action :provide_files, only: :create
      before_action :validate_files, only: :create
      before_action :import_claim, only: :create
      # This is sent the following parameters
      # new_claim - This contains the XML document
      # et1_<first_name>_<last_name>.pdf - An uploaded pdf file - note the varying parameter name - YUK
      def create
        render locals: { claim: claim }, status: :created
      end

      private

      def import_claim
        self.claim = import_service.import
        export_service.to_be_exported

      end

      def validate_files
        return if validator_service.valid?
        throw :abort
      end

      def claim_params
        params.require('new_claim')
      end

      def import_service
        @import_service ||= ClaimXmlImportService.new(claim_params)
      end

      def export_service
        @export_service ||= ClaimExportService.new(claim)
      end

      def validator_service
        @validator_service ||= ClaimXmlFileValidatorService.new(temp_files)
      end

      def temp_files
        @temp_files ||= begin
          files = import_service.files
          files.each_with_object({}) do |hash, acc|
            acc[hash[:filename]] = hash.merge(file: params.require(hash[:filename]))
          end
        end
      end

      def provide_files
        import_service.uploaded_files = temp_files
      end

      attr_accessor :claim
    end
  end
end
