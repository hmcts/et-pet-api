# frozen_string_literal: true

json.status 'not_accepted'
json.uuid command.uuid
json.errors api_errors(command)
