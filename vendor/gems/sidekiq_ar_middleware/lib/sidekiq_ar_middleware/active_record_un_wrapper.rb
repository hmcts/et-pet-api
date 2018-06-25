module SidekiqArMiddleware
  class ActiveRecordUnWrapper
    attr_reader :record
    def initialize(hash)
      self.record = load_record_from_hash(hash)
    end

    private

    def load_record_from_hash(hash)
      if hash.key?('record_id') && hash.key?('record_class_name')
        hash['record_class_name'].safe_constantize.find(hash['record_id'])
      else
        # @TODO Do this
        raise 'Not yet supported'
      end
    end

    attr_writer :record
  end
end
