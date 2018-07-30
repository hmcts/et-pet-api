# frozen_string_literal: true

module Api
  module V1
    # This claims controller is for V1 API which replaces the old JADU
    # system.  This will be deprecated and we will move over to V2 in time
    class ClaimsController < ::ApplicationController

      # This is sent the following parameters
      # new_claim - This contains the XML document
      # et1_<first_name>_<last_name>.pdf - An uploaded pdf file - note the varying parameter name - YUK
      def create
        root_object = Claim.new
        result = CommandService.dispatch root_object: root_object, data: {}, **command_data
        EventService.publish('ClaimFromXmlCreated', root_object, command: result)
        render locals: { result: result, data: root_object },
          status: (result.valid? ? :created : :unprocessable_entity)



        #render locals: { claim: claim }, status: :created
      end

      private

      def command_data
        {
          command: 'CreateClaimFromXml',
          uuid: SecureRandom.uuid,
          data: {
            xml: claim_params,
            files: temp_files
          }
        }
      end

      def claim_params
        params.require('new_claim')
      end

      def temp_files
        import_service ||= ClaimXmlImportService.new(claim_params)
        @temp_files ||= begin
          files = import_service.files
          files.each_with_object({}) do |hash, acc|
            acc[hash[:filename]] = hash.merge(file: params.require(hash[:filename]))
          end
        end
      end

      attr_accessor :claim
    end
  end
end
