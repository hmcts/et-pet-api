class ChangePrecisionOfQueriedHoursInResponses < ActiveRecord::Migration[5.2]
  def up
    change_column :responses, :queried_hours, :decimal, scale: 2, precision: 5
  end

  def down
    change_column :responses, :queried_hours, :decimal, scale: 2, precision: 4
  end
end
