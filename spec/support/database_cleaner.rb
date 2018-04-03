require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, { except: ['offices'] }

RSpec.configure do |c|
  c.before db_clean: true do
    DatabaseCleaner.clean
  end
end
