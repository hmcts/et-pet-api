# frozen_string_literal: true

module Api
  module V2
    module Respondents
      class BuildResponsesController < ::Api::V2::BaseController
        include CacheCommandResults

        cache_command_results only: :create

        def create
          root_object = ::Response.new
          command = CommandService.command_for(**build_response_params.merge(command: 'CreateResponse').to_h.symbolize_keys)
          if command.valid?
            result = CommandService.dispatch command: command, root_object: root_object
            render locals: { result: result }, status: (result.valid? ? :accepted : :unprocessable_entity)
          else
            render locals: { command: command }, status: :bad_request, template: 'api/v2/shared/command_errors'
          end
        end

        private

        def build_response_params
          params.permit(:uuid, :command, data: [:uuid, :command, data: {}]).to_h
        end
      end
    end
  end
end
