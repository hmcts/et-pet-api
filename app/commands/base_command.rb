class BaseCommand
  attr_reader :uuid, :data, :meta, :valid

  def initialize(uuid:, data:, command_service: CommandService)
    self.uuid = uuid
    self.data = data
    self.meta = {}
    self.valid = true
    self.command_service = command_service
  end

  def apply(_root_object)
    raise 'apply is to be implemented in the subclass'
  end

  def valid?
    valid
  end

  private

  attr_writer :uuid, :data, :meta, :valid
  attr_accessor :command_service
end
