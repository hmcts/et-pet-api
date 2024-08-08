class BooleanWithNaType < ::ActiveModel::Type::String

  private

  def cast_value(value)
    return super unless value.is_a?(TrueClass) || value.is_a?(FalseClass)

    super(value.to_s)
  end
end
