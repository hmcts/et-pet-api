module Api
  module V2
    class CreateBlobsController < BaseController
      def create
        root_object = {}
        command = CommandService.command_for(command: 'CreateBlob', uuid: SecureRandom.uuid, data: create_params.to_h.symbolize_keys)
        if command.valid?
          result = CommandService.dispatch root_object: root_object, command: command
          render locals: { result: result, data: root_object },
                 status: :accepted
        else
          render locals: { command: command }, status: :bad_request, template: 'api/v2/shared/command_errors'
        end
      end

      private

      def create_params
        params.permit(:file)
      end
    end
  end
end
