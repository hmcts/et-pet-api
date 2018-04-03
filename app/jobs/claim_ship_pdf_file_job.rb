class ClaimShipPdfFileJob < ApplicationJob
  queue_as :send_to_landing_folder

  def perform(file:, destination_filename:)
    raise 'Not yet implemented'
  end
end