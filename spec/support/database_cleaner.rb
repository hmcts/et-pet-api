require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, { except: ['offices', 'office_post_codes', 'unique_references', 'external_systems', 'external_system_configurations'] }

RSpec.configure do |c|
  c.around db_clean: true do |example|
    DatabaseCleaner.clean
    example.run
  end
end
