# frozen_string_literal: true
module Api
  module V2
    class ValidationController < ::Api::V2::BaseController
      VALID_COMMANDS = ["ValidateClaimantsFile"].freeze
      def validate
        command = CommandService.command_for(**validate_params.to_h.symbolize_keys)
        if command.valid?
          render locals: { command: command }, status: :ok
        else
          render locals: { command: command }, status: :bad_request, template: 'api/v2/shared/command_errors'
        end
      end

      private

      def validate_params
        params.permit(:uuid, :command, data: {})
      end
    end
  end
end
