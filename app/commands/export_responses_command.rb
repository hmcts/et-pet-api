class ExportResponsesCommand < BaseCommand
  attribute :external_system_id, :integer
  attribute :response_ids

  validate :validate_external_system_presence
  validate :validate_responses_presence

# @param [Export] root_object The export instance to populate
# @param [Hash] meta - Not used in this command
  def apply(root_object, meta: {})
    response_ids.each do |response_id|
      event_service.publish('ResponseExported', external_system_id: external_system_id, response_id: response_id)
    end
  end

  private

  def validate_external_system_presence
    return if ExternalSystem.where(id: external_system_id).count > 0

    errors.add :external_system_id, :external_system_not_found,
               external_system_id: external_system_id,
               uuid: uuid,
               command: command_name
  end

  def validate_responses_presence
    return if Response.where(id: response_ids).count == response_ids.length

    response_ids.each do |response_id|
      next unless Response.where(id: response_id).count.zero?

      errors.add :response_ids, :response_not_found,
                 response_id: response_id,
                 uuid: uuid,
                 command: command_name
    end
  end
end
