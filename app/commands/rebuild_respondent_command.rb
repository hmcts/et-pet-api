class RebuildRespondentCommand < BuildRespondentCommand
  def apply(root_object, **_args)
    new_attributes = attributes.dup
    if root_object.respondent.address_id && new_attributes.key?('address_attributes')
      new_attributes['address_attributes'].merge!('id' => root_object.respondent.address_id)
    end
    if root_object.respondent.work_address_id && new_attributes.key?('work_address_attributes')
      new_attributes['work_address_attributes'].merge!('id' => root_object.respondent.work_address_id)
    end
    root_object.respondent.attributes = new_attributes
    root_object.respondent.save(touch: false)
  end
end
