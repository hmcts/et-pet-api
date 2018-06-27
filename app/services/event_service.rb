# This service implements a basic publish/subscribe system, to begin with for
# in process communications only, but could be extended to across processes without
# changing the interface.
#
# Note that whilst it uses the 'wisper' gem internally, any code that is written for the handlers will
# know nothing about wisper and will just have a common 'handle' method. (The chances are we will remove wisper -
#  it just enabled us to get going quicker)
class EventService
  include Singleton

  class << self
    delegate :publish, :subscribe, :unsubscribe, :ignoring_events, to: :instance
  end

  delegate :publish, to: :publisher

  def publisher
    @publisher ||= Publisher.instance
  end

  def subscribe(event, handler, async: true, in_process: true)
    handler_proc = handler_proc_for(async, handler, in_process)
    publisher.on(event, &handler_proc)
    register_handler_proc(event, handler, handler_proc)
    self
  end

  def unsubscribe(event, handler)
    handlers = handler_procs.dig(event, handler)
    publisher.unsubscribe(*handlers)
  end

  def ignoring_events
    self.ignore_events = true
    yield
  ensure
    self.ignore_events = false
  end

  private

  def handler_proc_for(async, handler, in_process)
    lambda do |*args|
      next handle_sync(handler, args) if !async && in_process
      next handle_with_worker(args, handler) if async && !in_process
      raise 'Events can only handle sync in process or async out of process right now'
    end
  end

  def handle_sync(handler, args)
    handler_instance_for(handler).handle(*args) unless ignore_events
  end

  def handle_with_worker(args, handler)
    EventWorker.perform_async(handler, *args) unless ignore_events
  end

  def initialize(*)
    super
    self.handlers = {}
    self.handler_procs = {}
  end

  def register_handler_proc(event, handler, handler_proc)
    handler_procs[event] ||= {}
    handler_procs[event][handler] ||= []
    handler_procs[event][handler] << handler_proc
  end

  def handler_instance_for(klass)
    handlers[klass] ||= klass.new
  end

  attr_accessor :handlers, :ignore_events, :handler_procs

  class Publisher
    include Singleton
    include Wisper::Publisher

    def publish(*)
      super
    end

    def unsubscribe(*listeners)
      @local_registrations.delete_if do |registration|
        listeners.include?(registration.listener)
      end
    end
  end
end
