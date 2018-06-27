$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "sidekiq_ar_middleware/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "sidekiq_ar_middleware"
  s.version = SidekiqArMiddleware::VERSION
  s.authors = ["Gary Taylor"]
  s.email = ["gary.taylor@hmcts.net"]
  s.summary = %q{Use active record models with sidekiq workers}
  s.description = %q{This gem provides efficient support for active record models as parameters to your sidekiq workers}
  s.homepage = "https://github.com/ministryofjustice/et_api"
  s.license = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"
  s.add_dependency "rspec-rails", "~> 3.7"
  s.add_dependency "sidekiq", "~> 5.1"

  s.add_development_dependency "pg"
end
