class BaseCommand
  include ActiveModel::Model
  include ActiveModel::Attributes
  attr_reader :uuid

  def initialize(uuid:, data:, async: true, command_service: CommandService)
    self.uuid = uuid
    self.command_service = command_service
    super(data)
  end

  def apply(_root_object, meta: {})
    raise 'apply is to be implemented in the subclass'
  end

  private

  attr_writer :uuid
  attr_accessor :command_service
end
