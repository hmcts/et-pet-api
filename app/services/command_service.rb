class CommandService
  class CommandResponse
    def initialize(command:, meta: {})
      self.command = command
      self.meta = meta
    end
    attr_accessor :command, :meta

    def valid?(*args)
      command.valid?(*args)
    end

    delegate_missing_to :command
  end
  def self.dispatch(command:, root_object:, **args)
    command = command_for(command: command, **args) unless command.is_a?(BaseCommand)
    response = CommandResponse.new(command: command, meta: {})
    command.apply(root_object, meta: response.meta)
    response
  end

  def self.command_for(command:, uuid:, data:, async: true)
    command_class = "::#{command}Command".safe_constantize
    if command_class.nil?
      raise "Unknown command #{command} - Define a class called #{command}Command that extends BaseCommand"
    end

    command_class.new(uuid: uuid, data: data, async: async, command: command)
  end
end
