module Api
  module V2
    module References
      class CreateReferencesController < ::ApplicationController
        include CacheCommandResults

        cache_command_results only: :create

        def create
          root_object = {}
          result = CommandService.dispatch root_object: root_object, data: {}, **create_params.to_h.symbolize_keys
          render locals: { result: result, data: root_object },
                 status: (result.valid? ? :created : :unprocessable_entity)
        end

        private

        def create_params
          params.permit(:uuid, :command, data: {})
        end
      end
    end
  end
end
