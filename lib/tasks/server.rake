namespace :server do
  desc 'Start the server'
  task start: :db_migrate do
    ENV['PORT'] ||= '8080'
    require 'puma/cli'
    cli = Puma::CLI.new(['-p', ENV['PORT']])
    cli.run
  end

  desc 'Migrate the database with locking so only one process can run it at a time'
  task db_migrate: :environment do
    Rake::Task["db:migrate"].invoke
  rescue ActiveRecord::ConcurrentMigrationError => e
    # Log the error message and ignore
    Rails.logger.error("Concurrent migration error ignored: #{e.message}")
  end
end
