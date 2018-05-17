class SerialSequenceCommand < BaseCommand
  def apply(root_object)
    data.each do |command|
      result = command_service.dispatch root_object: root_object, **command.symbolize_keys
      unless result.valid?
        self.valid = false
        return nil
      end
      meta[command[:command]] = result.meta
    end
  end
end
