require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, { except: ['offices', 'office_post_codes', 'unique_references'] }

RSpec.configure do |c|
  c.before db_clean: true do
    DatabaseCleaner.clean
  end
end
