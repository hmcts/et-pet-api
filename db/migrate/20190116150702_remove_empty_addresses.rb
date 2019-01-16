class RemoveEmptyAddresses < ActiveRecord::Migration[5.2]
  class Address < ::ActiveRecord::Base
    self.table_name = :addresses
  end
  class Claimant < ::ActiveRecord::Base
    self.table_name = :claimants
  end
  class Respondent < ::ActiveRecord::Base
    self.table_name = :respondents
  end
  class Representative < ::ActiveRecord::Base
    self.table_name = :representatives
  end

  def up
    nil_address_ids = Address.where(street: nil, building: nil, locality: nil, county: nil, post_code: nil).pluck(:id)
    Claimant.where(address_id: nil_address_ids).update_all(address_id: nil)
    Respondent.where(address_id: nil_address_ids).update_all(address_id: nil)
    Respondent.where(work_address_id: nil_address_ids).update_all(work_address_id: nil)
    Representative.where(address_id: nil_address_ids).update_all(address_id: nil)
    Address.where(id: nil_address_ids).delete_all
  end

  def down
    # Do nothing
  end
end
