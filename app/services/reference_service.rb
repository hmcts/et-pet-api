# frozen_string_literal: true

# A service responsible for fetching the next reference for a claim / response
module ReferenceService
  def self.next_number
    ::UniqueReference.create.id
  end
end