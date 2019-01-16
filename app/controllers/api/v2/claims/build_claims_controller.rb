# frozen_string_literal: true

module Api
  module V2
    module Claims
      class BuildClaimsController < ::Api::V2::BaseController
        def create
          p = build_claims_params
          root_object = ::Claim.new
          command = CommandService.command_for command: p[:command],
                                           uuid: p[:uuid],
                                           data: sub_commands(p)
          if command.valid?
            result = CommandService.dispatch command: command, root_object: root_object
            # This is a bit of a frig - because we are not expecting the caller to
            # add the AssignReferenceToClaim command, we cant expect them to check the meta for
            # that command so we pretend its from the BuildClaim command instead
            result.meta['BuildClaim'] = result.meta.delete('AssignReferenceToClaim')
            root_object.save!
            EventService.publish('ClaimCreated', root_object)
            render locals: { result: result }, status: (result.valid? ? :accepted : :unprocessable_entity)
          else
            render locals: { command: command }, status: :bad_request, template: 'api/v2/shared/command_errors'
          end
        end

        private

        def sub_commands(claims_params)
          claims_params[:data].map(&:to_h) + [{ command: 'AssignReferenceToClaim', uuid: SecureRandom.uuid, data: {} }]
        end

        def build_claims_params
          params.permit!.to_h.slice(:uuid, :command, :data).tap do |p|
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
