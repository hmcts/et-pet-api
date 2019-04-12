# frozen_string_literal: true

json.status result.valid? ? 'accepted' : 'invalid'
json.meta result.meta
json.uuid result.uuid
