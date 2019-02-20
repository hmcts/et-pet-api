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
                                               data: sub_commands(p)
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

        def sub_commands(p)
          commands = p[:data].map(&:to_h)
          extra_commands = []
          build_response = commands.detect {|c| c[:command] == 'BuildResponse'}
          key = build_response[:data].delete(:additional_information_key)
          extra_commands << { uuid: SecureRandom.uuid, command: 'BuildResponseAdditionalInformationFile', data: { filename: 'additional_information.rtf', data_from_key: key } } unless key.nil?
          commands + extra_commands
        end

        def build_response_params
          params.permit(:uuid, :command, data: [:uuid, :command, data: {}])
        end
      end
    end
  end
end
