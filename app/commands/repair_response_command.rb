class RepairResponseCommand < BaseCommand
  attribute :response_id

  validate :validate_response_presence

  # @param [Hash] root_object Not used - nothing to update from using this command
  # @param [Hash] meta - Not used in this command
  def apply(root_object, meta: {})
    event_service.publish('ResponseRepairRequested', root_object)
  end

  private

  def response
    return @response if defined?(@response)

    @response = Response.find_by(id: response_id)
  end

  def validate_response_presence
    return if response.present?

    errors.add :response_id, :response_not_found,
               response_id: response_id,
               uuid: uuid,
               command: command_name
  end
end
