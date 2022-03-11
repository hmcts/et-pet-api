# frozen_string_literal: true
module Api
  module V2
    class ValidationController < ::Api::V2::BaseController
      VALID_COMMANDS = ["ValidateClaimantsFile"].freeze
      def validate
        root_object = {}
        command = CommandService.command_for(**validate_params.to_h.symbolize_keys)
        if command.valid?
          CommandService.dispatch command: command, root_object: root_object
          render locals: { command: command, root_object: root_object }, status: :ok
        else
          render locals: { command: command }, status: :unprocessable_entity, template: 'api/v2/shared/command_errors'
        end
      end

      private

      def validate_params
        params.permit(:uuid, :command, data: {})
      end
    end
  end
end
