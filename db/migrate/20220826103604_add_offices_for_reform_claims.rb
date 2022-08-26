class AddOfficesForReformClaims < ActiveRecord::Migration[7.0]
  class Office < ActiveRecord::Base
    self.table_name = :offices
  end

  def up
    (60..69).each do |office_code|
      Office.find_or_create_by(code: office_code.to_s, **leeds_attributes)
    end
    (80..89).each do |office_code|
      Office.find_or_create_by(code: office_code.to_s, **glasgow_attributes)
    end

  end

  def down
    # Deliberately not doing anything
  end

  def leeds_attributes
    {
      name: 'Leeds',
      address: '4th Floor, City Exchange, 11 Albion Street, Leeds LS1 5ES',
      telephone: '0113 245 9741',
      email: 'leedset@justice.gov.uk',
      is_default: false
    }
  end

  def glasgow_attributes
    {
      name: 'Glasgow',
      address: 'Eagle Building, 215 Bothwell Street, Glasgow, G2 7TS',
      telephone: '0141 204 0730',
      email: 'glasgowet@justice.gov.uk',
      is_default: false
    }
  end
end
