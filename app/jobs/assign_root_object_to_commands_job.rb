# frozen_string_literal: true

# A sidekiq job to assign root object to commands (as there was a period of about
#  6 months when they were not assigned)
class AssignRootObjectToCommandsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Command.transaction do
      Command.where(root_object_id: nil).or(Command.where(root_object_type: nil)).find_each do |command|

        request_json, response_json = command_parsed_json(command)

        update_response(command, request_json, response_json)
        update_claim(command, request_json, response_json)
      rescue ::JSON::ParserError
        next

      end
    end
  end

  private

  def update_response(command, request_json, response_json)
    return unless build_response?(request_json) && accepted?(response_json)

    response = find_response(response_json)
    return if response.nil?

    command.update root_object_id: response.id, root_object_type: 'Response'
  end

  def update_claim(command, request_json, response_json)
    return unless build_claim?(request_json) && accepted?(response_json)

    claim = find_claim(response_json)
    return if claim.nil?

    command.update root_object_id: claim.id, root_object_type: 'Claim'
  end

  def command_parsed_json(command)
    [JSON.parse(command.request_body), JSON.parse(command.response_body)]
  end

  def build_response?(request_json)
    request_json['command'] == 'SerialSequence' && request_json['data'].detect { |c| c['command'] == 'BuildResponse' }
  end

  def build_claim?(request_json)
    request_json['command'] == 'SerialSequence' && request_json['data'].detect { |c| c['command'] == 'BuildClaim' }
  end

  def accepted?(response_json)
    response_json['status'] == 'accepted'
  end

  def find_response(response_json)
    Response.find_by(reference: response_json.dig('meta', 'BuildResponse', 'reference'))
  end

  def find_claim(response_json)
    Claim.find_by(reference: response_json.dig('meta', 'BuildClaim', 'reference'))
  end
end
