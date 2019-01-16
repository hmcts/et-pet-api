class AddressValidator < ActiveModel::EachValidator
  VALID_ATTRIBUTES = ['building', 'street', 'locality', 'county', 'post_code'].freeze
  def validate_each(record, attribute, value)
    mark_with_error(record, attribute) && return if value.nil?
    return if options[:allow_empty] && value.empty?

    missing = VALID_ATTRIBUTES - value.keys.map(&:to_s)
    mark_with_error(record, attribute) unless missing.empty?
  end

  private

  def mark_with_error(record, attribute)
    record.errors.add attribute, :invalid_address
  end
end
