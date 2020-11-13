class MigrateCommandsWithNoRootObjectAgain < ActiveRecord::Migration[6.0]
  class Command < ActiveRecord::Base
    self.table_name = :commands
  end

  class Response < ActiveRecord::Base
    self.table_name = :responses
  end

  class Claim < ActiveRecord::Base
    self.table_name = :claims
  end

  def up
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

  def down
    # Do nothing
  end
end
