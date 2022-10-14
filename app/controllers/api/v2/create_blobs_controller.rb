module Api
  module V2
    class CreateBlobsController < ::ApplicationController
      def create
        root_object = {}
        result = CommandService.dispatch root_object: root_object, data: create_params.to_h.symbolize_keys, command: 'CreateBlob', uuid: SecureRandom.uuid
        render locals: { result: result, data: root_object },
               status: (result.valid? ? :accepted : :unprocessable_entity)
      end

      private

      def create_params
        params.permit(:file)
      end
    end
  end
end
