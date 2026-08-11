class RemoveSolidQueueTables < ActiveRecord::Migration[8.1]
  def up
    connection.disable_referential_integrity do
      drop_table :solid_queue_blocked_executions, if_exists: true, force: :cascade
      drop_table :solid_queue_claimed_executions, if_exists: true, force: :cascade
      drop_table :solid_queue_failed_executions, if_exists: true, force: :cascade
      drop_table :solid_queue_jobs, if_exists: true, force: :cascade
      drop_table :solid_queue_pauses, if_exists: true, force: :cascade
      drop_table :solid_queue_processes, if_exists: true, force: :cascade
      drop_table :solid_queue_ready_executions, if_exists: true, force: :cascade
      drop_table :solid_queue_recurring_executions, if_exists: true, force: :cascade
      drop_table :solid_queue_recurring_tasks, if_exists: true, force: :cascade
      drop_table :solid_queue_scheduled_executions, if_exists: true, force: :cascade
      drop_table :solid_queue_semaphores, if_exists: true, force: :cascade
    end
  end

  def down
    # Do nothing
  end
end
