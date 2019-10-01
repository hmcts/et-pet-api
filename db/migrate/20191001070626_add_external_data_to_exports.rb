class AddExternalDataToExports < ActiveRecord::Migration[6.0]
  def change
    add_column :exports, :external_data, :jsonb, default: {}, null: false
  end
end
