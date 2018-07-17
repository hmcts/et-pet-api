require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, { except: ['offices', 'office_post_codes'] }

RSpec.configure do |c|
  c.before do |example|
    DatabaseCleaner.clean unless example.metadata[:db_clean] == false
  end
end
