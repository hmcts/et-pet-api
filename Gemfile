source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '7.1.2'

# Azure deployment so we need this
gem 'azure_env_secrets', git: 'https://github.com/hmcts/azure_env_secrets.git', tag: 'v1.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

gem 'iodine', '~> 0.7.43'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.10'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Wisper is used as an in process pub/sub to decouple events / commands
gem 'uk_postcode', '~> 2.1'
gem 'wisper', git: 'https://github.com/krisleech/wisper.git', ref: '5587c1ad341a39f8d35d0a00ac78ba911e919b16'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'application_insights', git: 'https://github.com/microsoft/ApplicationInsights-Ruby.git', ref: '5db6b4'
gem 'et_azure_insights', '0.3.2', git: 'https://github.com/hmcts/et-azure-insights.git', tag: 'v0.3.2'
gem 'notifications-ruby-client', '~> 5.3'
gem "sentry-rails", "~> 5.7"
gem "sentry-ruby", "~> 5.7"
gem "sentry-sidekiq", "~> 5.7"
gem 'sidekiq', '< 7'
gem 'sidekiq_alive', '~> 2.0'
gem 'sidekiq-cron', '~> 1.1'
gem 'sidekiq-failures', '~> 1.0'

# Rubyzip used to produce and test zip files
gem 'rubyzip', '~> 2.0'

# Pdf forms to test pdf content and also to produce them
gem 'pdf-forms', '~> 1.3'

# Libreconv to convert various file formats.  Used to convert rtf / docx etc.. to pdf
gem 'libreconv', '~> 0.7'

# Azure
gem 'azure-storage-blob', '~> 2.0', '>= 2.0.1'

# For general easy http access - mainly for test but used in app too
gem 'dotenv-rails', '~> 2.7'
gem 'httparty', '~> 0.20'

gem 'rexml', '~> 3.2.5'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'bullet', '~> 7.0'
  gem 'bundler-audit', '~> 0.9.1'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'parallel_tests', '~> 4.1'
  gem 'rubocop', '~> 1.8', require: false
  gem "rubocop-rails", "~> 2.17", require: false
  gem 'rubocop-rspec', '~> 2.1', require: false
  gem 'rspec-rails', '~> 6.0'
  gem 'rspec_junit_formatter', '~> 0.6.0'
  gem 'simplecov', '~> 0.21', require: false
  gem 'site_prism', '~> 4.0'
end

group :development do
  gem 'listen', '~> 3.4'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.1'
  gem 'spring-watcher-listen', '~> 2.1.0'
end

group :test do
  gem 'database_cleaner', '~> 2.0'
  gem 'et_fake_acas_server', '~> 2.0'
  gem 'factory_bot', '~> 6.1'
  gem 'faker', '~> 3.1'
  gem 'gov_fake_notify', '~> 1.2'
  gem "pdf-reader", "~> 2.4"
  gem 'puma', '~> 6.3'
  gem 'rspec-eventually', '~> 0.2.2'
  gem "selenium-webdriver", "~> 4.10"
  gem 'super_diff', '~> 0.10.0'
  gem 'webmock', '~> 3.11'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'et_acas_api', path: 'vendor/gems/et_acas_api'

gem 'et_exporter', git: 'https://github.com/hmcts/et_exporter_gem.git', tag: 'v1.0.0'

gem "activerecord-nulldb-adapter", "~> 1.0", group: :test
