# frozen_string_literal: true

module Api
  module V2
    module Respondents
      class BuildResponsesController < ::Api::V2::BaseController
        def create
          p = build_response_params
          root_object = ::Response.new
          command = CommandService.command_for command: p[:command],
                                               uuid: p[:uuid],
                                               data: p[:data].map(&:to_h)
          if command.valid?
            result = CommandService.dispatch command: command, root_object: root_object
            root_object.save!
            EventService.publish('ResponseCreated', root_object)
            render locals: { result: result }, status: (result.valid? ? :accepted : :unprocessable_entity)
          else
            render locals: { command: command }, status: :bad_request, template: 'api/v2/shared/command_errors'
          end
        end

        private

        def build_response_params
          params.permit(:uuid, :command, data: [:uuid, :command, data: {}])
        end
      end
    end
  end
end
