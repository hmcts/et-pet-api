class StrippedStringType < ::ActiveModel::Type::String

  private

  def cast_value(value)
    return super(value) unless value.respond_to?(:strip)
    super(value.strip)
  end
end
