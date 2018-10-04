# frozen_string_literal: true

module Api
  module V2
    module Claims
      class BuildClaimsController < ::ApplicationController
        def create
          p = build_claims_params
          root_object = ::Claim.new
          result = CommandService.dispatch command: p[:command],
                                           uuid: p[:uuid],
                                           data: sub_commands(p),
                                           root_object: root_object
          # This is a bit of a frig - because we are not expecting the caller to add the AssignReferenceToClaim command, we
          # cant expect them to check the meta for that command so we pretend its from the BuildClaim command instead
          result.meta['BuildClaim'] = result.meta.delete('AssignReferenceToClaim')
          root_object.save!
          EventService.publish('ClaimCreated', root_object)
          render locals: { result: result }, status: (result.valid? ? :accepted : :unprocessable_entity)
        end

        private

        def sub_commands(p)
          p[:data].map(&:to_h) + [{ command: 'AssignReferenceToClaim', uuid: SecureRandom.uuid, data: {} }]
        end

        def build_claims_params
          params.permit!.to_h.slice(:uid, :command, :data).tap do |p|
            if p[:data].is_a?(Array)
              p[:data] = p[:data].map do |sub_command|
                sub_command.slice(:uuid, :command, :data)
              end
            end
          end
        end
      end
    end
  end
end
