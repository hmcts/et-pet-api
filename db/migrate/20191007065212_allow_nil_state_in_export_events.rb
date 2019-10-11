class AllowNilStateInExportEvents < ActiveRecord::Migration[6.0]
  def change
    change_column_null :export_events, :state, true
    change_column_default :export_events, :state, nil
  end
end
