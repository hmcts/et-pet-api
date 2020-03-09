# frozen_string_literal: true

json.status result.valid? ? 'accepted' : 'invalid'
json.uuid result.uuid
