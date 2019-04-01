class CreateResponseCommand < SerialSequenceCommand
  def initialize(uuid:, data:, **args)
    extra_commands = []
    build_response = data.detect { |c| c[:command] == 'BuildResponse' }
    key = build_response[:data].delete(:additional_information_key)
    unless key.nil?
      extra_commands << { uuid: SecureRandom.uuid, command: 'BuildResponseAdditionalInformationFile',
                          data: { filename: 'additional_information.rtf', data_from_key: key } }
    end
    super uuid: uuid, data: data + extra_commands, **args
  end

  def apply(root_object, meta: {})
    super
    root_object.save!
    EventService.publish('ResponseCreated', root_object)
  end

end
