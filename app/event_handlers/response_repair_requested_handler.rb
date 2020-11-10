class ResponseRepairRequestedHandler
  def handle(response)
    response.events.response_repair_requested.create
    original_command = response.commands.first
    request_json = ::JSON.parse(original_command.request_body).deep_symbolize_keys
    return unless request_json[:data].is_a?(Array)

    converted_json = convert_to_repair_commands(request_json)

    CommandService.dispatch root_object: response, **converted_json
    Rails.application.event_service.publish('ResponseRepaired', response)
  end

  def convert_to_repair_commands(json)
    converted_json = json.dup
    converted_json[:command] = 'RecreateResponse'
    converted_json[:data].each do |command|
      command[:command] = command[:command].gsub(/Build/, 'Rebuild')
    end
    converted_json
  end
end
