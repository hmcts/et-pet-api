source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'

# Azure deployment so we need this
gem 'azure_env_secrets', git: 'https://github.com/ministryofjustice/azure_env_secrets.git', tag: 'v0.1.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

gem 'iodine', '~> 0.7.33'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.9'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Wisper is used as an in process pub/sub to decouple events / commands
gem 'wisper', '2.0.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'sidekiq', '~> 5.2'
gem 'sidekiq-cron', '~> 1.1'
gem 'sidekiq-failures', '~> 1.0'
gem 'sidekiq_alive', '~> 1.0'
gem 'sentry-raven', '~> 2.11'

# ET to ATOS File transfer packaged as a rack endpoint (rails engine) for easy deployment as a separate service.
# Note that we are now using it as a separate service, but we need this gem just for the model for now
# (and we need it for test environment)
gem 'et_atos_file_transfer', git: 'https://github.com/ministryofjustice/et_atos_file_transfer.git', ref: '88b5f417f7eaf1739c24e57c6c9e28befa30d09f'
gem 'et_atos_export', path: 'vendor/gems/et_atos_export'

# Rubyzip used to produce and test zip files
gem 'rubyzip', '~> 2.0'

# Pdf forms to test pdf content and also to produce them
gem 'pdf-forms', '~> 1.2'

# Azure
gem 'azure-storage', '~> 0.15.0.preview', require: false

# For general easy http access - mainly for test but used in app too
gem 'httparty', '~> 0.17'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8'
  gem 'simplecov', '~> 0.17'
  gem 'dotenv-rails', '~> 2.4'
  gem 'site_prism', '~> 3.2'
  gem 'rspec_api_documentation', '~> 6.1'
  gem 'bullet', '~> 6.0'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.1.0'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'rubocop', '~> 0.74'
  gem 'rubocop-rspec', '~> 1.33'
end

group :test do
  gem 'database_cleaner', '~> 1.7'
  gem 'factory_bot', '~> 5.0'
  gem 'rspec-eventually', '~> 0.2.2'
  gem 'faker', '~> 2.1'
  gem 'webmock', '~> 3.7'
  gem 'et_fake_acas_server', git: 'https://github.com/ministryofjustice/et_fake_acas_server.git', ref: 'c96de4295f35fc2d6518bde96846eda8fb9042e3'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'et_acas_api', path: 'vendor/gems/et_acas_api'

gem 'et_exporter', git: 'https://github.com/hmcts/et_exporter_gem.git', tag: 'v0.3.9-rc1'
