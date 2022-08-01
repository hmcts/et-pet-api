Rails.configuration.to_prepare do
  ActiveModel::Type.register :address_hash, AddressHashType
  ActiveModel::Type.register :stripped_string, StrippedStringType
end
