# frozen_string_literal: true

json.status result.status
json.errors do
  json.merge! result.errors
end
