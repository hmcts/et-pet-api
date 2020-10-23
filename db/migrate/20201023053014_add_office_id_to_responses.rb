class AddOfficeIdToResponses < ActiveRecord::Migration[6.0]
  def change
    add_column :responses, :office_id, :integer
    add_index :responses, :office_id
  end
end
