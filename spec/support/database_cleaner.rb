require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, { except: ['offices', 'office_post_codes', 'unique_references'] }

RSpec.configure do |c|
  c.around db_clean: true do |example|
    DatabaseCleaner.clean
    example.run
  end
end
