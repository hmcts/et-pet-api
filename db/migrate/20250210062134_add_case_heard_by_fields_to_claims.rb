class AddCaseHeardByFieldsToClaims < ActiveRecord::Migration[7.2]
  def change
    add_column :claims, :case_heard_by_preference, :string
    add_column :claims, :case_heard_by_preference_reason, :string
  end
end
