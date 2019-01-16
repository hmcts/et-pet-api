class SerialSequenceCommand < BaseCommand
  attribute :data
  validate :validate_all_commands

  def initialize(uuid:, data:, **args)
    super(uuid: uuid, data: {}, **args)
    initialize_commands(data)
  end

  def apply(root_object, meta: {})
    data.each do |command|
      result = command_service.dispatch root_object: root_object, command: command
      meta[command.command_name] = result.meta
    end
  end

  private

  def initialize_commands(commands)
    self.data = commands.map do |command|
      command_service.command_for(command.symbolize_keys)
    end
  end

  def validate_all_commands
    data.each do |command|
      next if command.valid?

      validate_command(command)
    end
  end

  def validate_command(command)
    pos = data.index { |c| c.uuid == command.uuid }
    command.errors.details.each_pair do |attr, command_errors|
      add_error_for(attr, command, command_errors, pos)
    end
  end

  def add_error_for(attr, command, command_errors, pos)
    messages = command.errors.messages[attr]
    command_errors.each_with_index do |error, idx|
      extra_error_details = {
        uuid: command.uuid,
        command: command.command_name
      }
      errors.add(:"data[#{pos}].#{attr}", messages[idx], error.merge(extra_error_details))
    end
  end
end
