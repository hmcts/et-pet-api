class RebuildRepresentativeCommand < BuildRepresentativeCommand
  def apply(root_object, **_args)
    new_attributes = attributes.dup
    if root_object.representative.address_id && new_attributes.key?('address_attributes')
      new_attributes['address_attributes'].merge!('id' => root_object.representative.address_id)
    end
    root_object.representative.attributes = new_attributes
    root_object.representative.save(touch: false)
  end
end
