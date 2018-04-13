$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "et_atos_file_transfer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "et_atos_file_transfer"
  s.version     = EtAtosFileTransfer::VERSION
  s.authors     = ["Gary Taylor"]
  s.email       = ["gary.taylor@hmcts.net"]
  s.homepage    = "https://github.com/ministryofjustice/et_api"
  s.summary     = %q{ET to ATOS File Transfer}
  s.description = %q{This gem provides the file transfer protocol required by the ATOS system - for the ET JADU Replacement Project}
  s.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if s.respond_to?(:metadata)
    s.metadata["allowed_push_host"] = "http://nonexistentgemserver.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end


  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2"

  s.add_development_dependency "pg"
end
