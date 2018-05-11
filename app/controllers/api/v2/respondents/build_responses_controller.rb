# frozen_string_literal: true

module Api
  module V2
    module Respondents
      class BuildResponsesController < ::ApplicationController
        def create
          p = build_response_params
          root_object = ::Response.new
          result = CommandService.dispatch command: p[:command],
                                           uuid: p[:uuid],
                                           data: p[:data].map(&:to_h),
                                           root_object: root_object
          root_object.save!
          EventService.publish('ResponseCreated', root_object)
          render locals: { result: result }, status: (result.valid? ? :accepted : :unprocessable_entity)
        end

        private

        def build_response_params
          params.permit(:uuid, :command, data: [:uuid, :command, data: {}])
        end
      end
    end
  end
end
