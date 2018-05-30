class BaseCommand
  attr_reader :uuid, :input_data, :meta, :valid, :async, :output_data

  def initialize(uuid:, data:, async: true, command_service: CommandService)
    self.uuid = uuid
    self.input_data = data
    self.meta = {}
    self.output_data = {}
    self.valid = true
    self.async = async
    self.command_service = command_service
  end

  def apply(_root_object)
    raise 'apply is to be implemented in the subclass'
  end

  def valid?
    valid
  end

  private

  attr_writer :uuid, :input_data, :meta, :valid, :async, :output_data
  attr_accessor :command_service
end
