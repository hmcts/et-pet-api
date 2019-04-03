module Api
  module V2
    class BuildBlobsController < ::ApplicationController
      include CacheCommandResults

      cache_command_results only: :create

      def create
        root_object = {}
        result = CommandService.dispatch root_object: root_object, data: {}, **create_params.to_h.symbolize_keys
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
