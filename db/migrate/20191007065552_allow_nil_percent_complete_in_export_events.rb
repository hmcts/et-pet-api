class AllowNilPercentCompleteInExportEvents < ActiveRecord::Migration[6.0]
  def change
    change_column_null :export_events, :percent_complete, true
    change_column_default :export_events, :percent_complete, nil
  end
end
