class AddressHashType < ::ActiveModel::Type::Value
  def assert_valid_value(value)
    unless value.respond_to?(:keys) && value.stringify_keys.keys == ['building', 'street', 'locality', 'county', 'post_code']
      raise ArgumentError, "'#{value}' is not a valid #{name}"
    end
  end

  private

  def cast_value(value)
    return nil if value.nil?

    v = value.with_indifferent_access
    v[:post_code]&.strip!
    v[:building]&.strip!
    v[:street]&.strip!
    v[:county]&.strip!
    v[:post_code]&.strip!
    v
  end
end
