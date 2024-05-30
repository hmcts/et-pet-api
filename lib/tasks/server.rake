namespace :server do
  desc 'Start the server'
  task start: :db_migrate do
    ENV['PORT'] ||= '8080'
    Iodine::Rack.run EtApi::Application

    # Start the server
    Iodine.start
  end

  desc 'Migrate the database with locking so only one process can run it at a time'
  task db_migrate: :environment do
    Rake::Task["db:migrate"].invoke
  rescue ActiveRecord::ConcurrentMigrationError => e
    # Log the error message and ignore
    Rails.logger.error("Concurrent migration error ignored: #{e.message}")
  end
end
