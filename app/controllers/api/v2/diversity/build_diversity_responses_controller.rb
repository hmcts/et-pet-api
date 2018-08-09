# frozen_string_literal: true

module Api
  module V2
    module Diversity
      class BuildDiversityResponsesController < ::ApplicationController
        def create
          p = build_diversity_response_params
          root_object = ::DiversityResponse.new
          result = CommandService.dispatch command: p[:command],
                                           uuid: p[:uuid],
                                           data: p[:data],
                                           root_object: root_object
          root_object.save! if result.valid?
          EventService.publish('DiversityResponseCreated', root_object)
          render locals: { result: result }, status: (result.valid? ? :created : :unprocessable_entity)
        end

        private

        def build_diversity_response_params
          params.permit(:uuid, :command, data: [
                          :claim_type, :sex, :sexual_identity, :age_group, :ethnicity, :ethnicity_subgroup, :disability,
                          :caring_responsibility, :gender, :gender_at_birth, :pregnancy, :relationship, :religion
                        ])
        end
      end
    end
  end
end
