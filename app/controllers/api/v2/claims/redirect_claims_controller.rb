# frozen_string_literal: true

module Api
  module V2
    module Claims
      class RedirectClaimsController < ::Api::V2::BaseController
        include CacheCommandResults

        cache_command_results only: :create

        def create
          root_object = ::Claim.find_by(id: redirect_claims_params.dig(:data, :claim_id))
          command = CommandService.command_for(**redirect_claims_params.merge(command: 'RedirectClaim').symbolize_keys)
          if command.valid?
            result = CommandService.dispatch command: command, root_object: root_object
            render locals: { result: result }, status: (result.valid? ? :accepted : :unprocessable_entity)
            self.cached_root_object = root_object
          else
            render locals: { command: command }, status: :bad_request, template: 'api/v2/shared/command_errors'
          end
        end

        private

        def redirect_claims_params
          params.permit!.to_h.slice(:uuid, :command, :data)
        end
      end
    end
  end
end
