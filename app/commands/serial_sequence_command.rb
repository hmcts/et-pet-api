class SerialSequenceCommand < BaseCommand
  attribute :command_hashes
  attribute :commands
  validate :validate_all_commands

  def initialize(uuid:, data:, **args)
    super(uuid: uuid, data: { command_hashes: data }, **args)
    initialize_commands
  end

  def apply(root_object, meta: {})
    command_hashes.each do |command|
      result = command_service.dispatch root_object: root_object, **command.symbolize_keys
      meta[command[:command]] = result.meta
    end
  end

  private

  def initialize_commands
    self.commands = command_hashes.map do |command|
      command_service.command_for(command.symbolize_keys)
    end
  end

  def validate_all_commands
    errors.add(:commands, :invalid_commands) unless commands.all?(&:valid?)
  end
end
