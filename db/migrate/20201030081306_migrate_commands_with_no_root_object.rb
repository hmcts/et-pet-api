class MigrateCommandsWithNoRootObject < ActiveRecord::Migration[6.0]
  def up
    # Do nothing - this migration was breaking deployment for some reason so moved it to a sidekiq job
  end

  def down
    # Do nothing
  end
end
