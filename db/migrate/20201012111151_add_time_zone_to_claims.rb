class AddTimeZoneToClaims < ActiveRecord::Migration[6.0]
  def change
    add_column :claims, :time_zone, :string, default: 'London', null: false
  end
end
