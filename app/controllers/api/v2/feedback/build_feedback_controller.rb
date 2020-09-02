# frozen_string_literal: true

module Api
  module V2
    module Feedback
      class BuildFeedbackController < ::ApplicationController
        include CacheCommandResults

        cache_command_results only: :create

        def create
          p = build_feedback_params.merge(command: 'BuildFeedback').to_h.symbolize_keys
          root_object = {}
          result = CommandService.dispatch root_object: root_object, **p
          render locals: { result: result }, status: (result.valid? ? :created : :unprocessable_entity)
          self.cached_root_object = root_object
        end

        private

        def build_feedback_params
          params.permit(:uuid, :command, data: [:problems, :suggestions, :email_address])
        end
      end
    end
  end
end
