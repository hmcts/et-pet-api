class AddNotNullToExternalServiceIdInExports < ActiveRecord::Migration[5.2]
  def change
    change_column_null :exports, :external_system_id, false
  end
end
