class AddExportFeedbackQueueToExternalSystems < ActiveRecord::Migration[6.0]
  def change
    add_column :external_systems, :export_feedback_queue, :string, null: false, default: 'default'
  end
end
