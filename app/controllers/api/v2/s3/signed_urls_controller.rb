module Api
  module V2
    module S3
      class SignedUrlsController < ::ApplicationController
        def create
          root_object = {}
          result = CommandService.dispatch root_object: root_object, data: {}, **create_params.to_h.symbolize_keys
          EventService.publish('SignedS3FormDataCreated', root_object)
          render locals: { result: result, data: root_object },
                 status: (result.valid? ? :accepted : :unprocessable_entity)
        end

        private

        def create_params
          params.permit(:uuid, :command, :async, data: {})
        end

      end
    end
  end
end
