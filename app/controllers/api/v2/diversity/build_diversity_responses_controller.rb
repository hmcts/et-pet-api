# frozen_string_literal: true

module Api
  module V2
    module Diversity
      class BuildDiversityResponsesController < ::ApplicationController
        include CacheCommandResults

        cache_command_results only: :create

        def create
          p = build_diversity_response_params.merge(command: 'CreateDiversityResponse').to_h.symbolize_keys
          root_object = ::DiversityResponse.new
          result = CommandService.dispatch root_object: root_object, **p
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
