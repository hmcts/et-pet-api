$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "et_acas_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "et_acas_api"
  s.version     = EtAcasApi::VERSION
  s.authors     = ["Gary Taylor"]
  s.email       = ["gary.taylor@hmcts.net"]
  s.homepage    = "https://github.com/ministryofjustice/et_api"
  s.summary     = "Employment Tribunal ACAS Interface"
  s.description = "Employment Tribunal ACAS Interface and fake server"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"
  s.add_dependency 'pg', '>= 0.18', '< 2.0'
  s.add_dependency 'activerecord-nulldb-adapter', '~> 0.3.8'

end
