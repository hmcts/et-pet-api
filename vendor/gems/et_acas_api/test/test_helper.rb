# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../spec/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../spec/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new


# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixtures_path=)
  ActiveSupport::TestCase.fixtures_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixtures_path = ActiveSupport::TestCase.fixtures_path
  ActiveSupport::TestCase.file_fixtures_path = ActiveSupport::TestCase.fixtures_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end
