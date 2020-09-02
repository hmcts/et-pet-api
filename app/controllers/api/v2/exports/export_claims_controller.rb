module Api
  module V2
    module Exports
      class ExportClaimsController < ::Api::V2::BaseController
        include CacheCommandResults

        cache_command_results only: :create

        def create
          root_object = {}
          command = CommandService.command_for(**export_claims_params.merge(command: 'ExportClaims').symbolize_keys)
          if command.valid?
            result = CommandService.dispatch command: command, root_object: root_object
            render locals: { result: result }, status: (result.valid? ? :accepted : :unprocessable_entity)
            self.cached_root_object = root_object
          else
            render locals: { command: command }, status: :bad_request, template: 'api/v2/shared/command_errors'
          end
        end

        private

        def export_claims_params
          params.permit!.to_h.slice(:uuid, :command, :data)
        end
      end
    end
  end
end
