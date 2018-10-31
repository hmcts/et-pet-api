class UpdateDefaultEmploymentDetails < ActiveRecord::Migration[5.2]
  def up
    Claim.where(employment_details: "{}").update_all(employment_details: {})
  end

  def down; end
end
