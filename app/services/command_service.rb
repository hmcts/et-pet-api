class CommandService
  def self.dispatch(command:, uuid:, data:, root_object:, async: true)
    command_class = "::#{command}Command".safe_constantize
    if command_class.nil?
      raise "Unknown command #{command} - Define a class called #{command}Command that extends BaseCommand"
    end
    command_class.new(uuid: uuid, data: data, async: async).tap do |cmd|
      cmd.apply(root_object)
    end
  end
end
