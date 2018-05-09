class CommandService
  def self.dispatch(command:, uuid:, data:, root_object:)
    command_class = "::#{command}Command".safe_constantize
    raise "Unknown command #{command} - Define a class called #{command}Command that extends BaseCommand" if command_class.nil?
    command_class.new(uuid: uuid, data: data).tap do |cmd|
      cmd.apply(root_object)
    end
  end
end
