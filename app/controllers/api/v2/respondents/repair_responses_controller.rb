# frozen_string_literal: true

module Api
  module V2
    module Respondents
      class RepairResponsesController < ::Api::V2::BaseController
        include CacheCommandResults
        include ResponsesSentryContext

        cache_command_results only: :create

        def create
          root_object = ::Response.find_by(id: repair_response_params.dig(:data, :response_id))
          set_sentry_response(root_object)
          command = CommandService.command_for(**repair_response_params.merge(command: 'RepairResponse').to_h.symbolize_keys)
          if command.valid?
            result = CommandService.dispatch command: command, root_object: root_object
            render locals: { result: result }, status: (result.valid? ? :accepted : :unprocessable_entity)
            self.cached_root_object = root_object
          else
            render locals: { command: command }, status: :bad_request, template: 'api/v2/shared/command_errors'
          end
        end

        private

        def repair_response_params
          params.permit(:uuid, :command, data: {}).to_h
        end
      end
    end
  end
end
