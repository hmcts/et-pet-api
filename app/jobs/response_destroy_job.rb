# frozen_string_literal: true

class ResponseDestroyJob < ApplicationJob
  queue_as :default

  def perform(response_id)
    Response.find(response_id).destroy!
  end
end
