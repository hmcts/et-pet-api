class BaseCommand
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks
  attr_reader :uuid, :command_name

  # Creates a new command
  # @param [String] uuid The unique id of the command
  # @param [Hash] data The data for the command
  # @param [Boolean] async If true, the command handler will run in background
  def initialize(uuid:, data:, async: true, command_service: CommandService, event_service: EventService,
    command: self.class.name.try(:demodulize).try(:gsub, /Command\Z/, ''))
    self.uuid = uuid
    self.command_name = command
    self.command_service = command_service
    self.event_service = event_service
    self.async = async
    super(with_extra_attrs_ignored(data))
  end

  # Apply changes to the root object based on the command data - always overriden in sub class
  # @param [Object] root_object Any object which has changes applied to it by the command
  # @param [Hash] meta A general purpose hash for use when the caller needs some feedback before the
  #   command is started. Defaults to empty hash
  def apply(_root_object, meta: {}) # rubocop:disable Lint/UnusedMethodArgument
    raise 'apply is to be implemented in the subclass'
  end

  private

  attr_writer :uuid, :command_name
  attr_accessor :command_service, :event_service, :async

  def with_extra_attrs_ignored(data)
    attrs_defined = self.class._default_attributes.keys.map(&:to_s)
    data.stringify_keys.slice(*attrs_defined)
  end
end
