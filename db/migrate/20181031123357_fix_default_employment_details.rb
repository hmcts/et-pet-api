class FixDefaultEmploymentDetails < ActiveRecord::Migration[5.2]
  def change
    change_column :claims, :employment_details, :jsonb, default: {}, null: false
  end

  def down
    change_column :claims, :employment_details, :jsonb, default: "{}", null: false
  end
end
