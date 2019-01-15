class AddressHashType < ::ActiveModel::Type::Value
  def assert_valid_value(value)
    return if value.blank?
    return if value.respond_to?(:keys) && value.stringify_keys.keys == ['building', 'street', 'locality', 'county', 'post_code']

    raise ArgumentError, "'#{value}' is not a valid Address Hash"
  end

  private

  def cast_value(value)
    v = value.with_indifferent_access
    v[:post_code]&.strip!
    v[:building]&.strip!
    v[:street]&.strip!
    v[:county]&.strip!
    v[:post_code]&.strip!
    v
  end
end
