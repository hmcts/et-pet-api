class BaseCommand
  include ActiveModel::Model
  include ActiveModel::Attributes
  attr_reader :uuid

  # Creates a new command
  # @param [String] uuid The unique id of the command
  # @param [Hash] data The data for the command
  # @param [Boolean] async If true, the command handler will run in background
  def initialize(uuid:, data:, async: true, command_service: CommandService)
    self.uuid = uuid
    self.command_service = command_service
    self.async = async
    super(data)
  end

  # Apply changes to the root object based on the command data - always overriden in sub class
  # @param [Object] root_object Any object which has changes applied to it by the command
  # @param [Hash] meta A general purpose hash for use when the caller needs some feedback before the command is started. Defaults to empty hash
  def apply(_root_object, meta: {}) # rubocop:disable Lint/UnusedMethodArgument
    raise 'apply is to be implemented in the subclass'
  end

  private

  attr_writer :uuid
  attr_accessor :command_service, :async
end
