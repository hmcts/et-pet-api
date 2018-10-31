class UpdateDefaultEmploymentDetails < ActiveRecord::Migration[5.2]
  class Claim < ActiveRecord::Base
    self.table_name = :claims
  end

  def up
    Claim.where(employment_details: "{}").update_all(employment_details: {})
  end

  def down; end
end
