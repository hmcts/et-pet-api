# frozen_string_literal: true

# A sidekiq job to assign root object to commands (as there was a period of about
#  6 months when they were not assigned)
class EventJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Command.transaction do
      Command.where(root_object_id: nil).or(Command.where(root_object_type: nil)).find_each do |command|
        begin
          request_json = JSON.parse(command.request_body)
          response_json = JSON.parse(command.response_body)

          if request_json['command'] == 'SerialSequence' && request_json['data'].detect {|c| c['command'] == 'BuildResponse'}
            next unless response_json['status'] == 'accepted'

            response = Response.find_by(reference: response_json.dig('meta', 'BuildResponse', 'reference'))
            next if response.nil?

            command.update root_object_id: response.id, root_object_type: 'Response'
          elsif request_json['command'] == 'SerialSequence' && request_json['data'].detect {|c| c['command'] == 'BuildClaim'}
            next unless response_json['status'] == 'accepted'

            claim = Claim.find_by(reference: response_json.dig('meta', 'BuildClaim', 'reference'))
            next if claim.nil?

            command.update root_object_id: claim.id, root_object_type: 'Claim'
          end

        rescue ::JSON::ParserError
          next
        end

      end
    end

  end
end
