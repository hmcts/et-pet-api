source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.1.2.1'

# Azure deployment so we need this
gem 'azure_env_secrets', git: 'https://github.com/ministryofjustice/azure_env_secrets.git', tag: 'v0.1.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

gem 'iodine', '~> 0.7.43'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.10'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Wisper is used as an in process pub/sub to decouple events / commands
gem 'wisper', '~> 2.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'sidekiq', '~> 6.1'
gem 'sidekiq-cron', '~> 1.1'
gem 'sidekiq-failures', '~> 1.0'
gem 'sidekiq_alive', '~> 2.0'
gem 'sentry-raven', '~> 3.1'
gem 'et_azure_insights', '0.2.12', git: 'https://github.com/hmcts/et-azure-insights.git', tag: 'v0.2.12'
gem 'application_insights', git: 'https://github.com/microsoft/ApplicationInsights-Ruby.git', ref: '5db6b4'
# ET to ATOS File transfer packaged as a rack endpoint (rails engine) for easy deployment as a separate service.
# Note that we are now using it as a separate service, but we need this gem just for the model for now
# (and we need it for test environment)
gem 'et_atos_file_transfer', git: 'https://github.com/ministryofjustice/et_atos_file_transfer.git', tag: 'v2.0.0'
gem 'et_atos_export', path: 'vendor/gems/et_atos_export'
gem 'notifications-ruby-client', '~> 5.3'

# Rubyzip used to produce and test zip files
gem 'rubyzip', '~> 2.0'

# Pdf forms to test pdf content and also to produce them
gem 'pdf-forms', '~> 1.3'

# Azure
gem 'azure-storage-blob', '~> 2.0', '>= 2.0.1'

# For general easy http access - mainly for test but used in app too
gem 'httparty', '~> 0.17'
gem 'dotenv-rails', '~> 2.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 4.0'
  gem 'simplecov', '~> 0.21'
  gem 'site_prism', '~> 3.7'
  gem 'bullet', '~> 6.1'
end

group :development do
  gem 'listen', '~> 3.4'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.1'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rubocop', '~> 1.18'
  gem 'rubocop-rspec', '~> 2.1'
end

group :test do
  gem 'database_cleaner', '~> 2.0'
  gem 'factory_bot', '~> 6.1'
  gem 'rspec-eventually', '~> 0.2.2'
  gem 'faker', '~> 2.15'
  gem 'webmock', '~> 3.11'
  gem 'et_fake_acas_server', '~> 0.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'et_acas_api', path: 'vendor/gems/et_acas_api'

gem 'et_exporter', git: 'https://github.com/hmcts/et_exporter_gem.git', tag: 'v0.4.11'
