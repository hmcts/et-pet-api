# frozen_string_literal: true

module Api
  module V2
    module Claims
      class BuildClaimsController < ::Api::V2::BaseController
        include CacheCommandResults

        cache_command_results only: :create

        def create
          root_object = ::Claim.new
          command = CommandService.command_for(**build_claims_params.merge(command: 'CreateClaim').symbolize_keys)
          if command.valid?
            result = CommandService.dispatch command: command, root_object: root_object
            render locals: { result: result }, status: (result.valid? ? :accepted : :unprocessable_entity)
          else
            render locals: { command: command }, status: :bad_request, template: 'api/v2/shared/command_errors'
          end
        end

        private

        def build_claims_params
          params.permit!.to_h.slice(:uuid, :command, :data).tap do |p|
            if p[:data].is_a?(Array)
              p[:data] = p[:data].map do |sub_command|
                sub_command.slice(:uuid, :command, :data)
              end
            end
          end
        end
      end
    end
  end
end
