$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "et_atos_export/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "et_atos_export"
  s.version     = EtAtosExport::VERSION
  s.authors     = ["Gary Taylor"]
  s.email       = ["gary.taylor@hismessages.com"]
  s.homepage    = "http://www.google.com"
  s.summary     = "Used alongside et_atos_file_transfer gem"
  s.description = "Exports files ready for et_atos_file_transfer gem to pick up"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.2.1"

  s.add_development_dependency "pg"
end
