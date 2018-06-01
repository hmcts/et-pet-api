
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fake_acas_server/version"

Gem::Specification.new do |spec|
  spec.name          = "fake_acas_server"
  spec.version       = FakeAcasServer::VERSION
  spec.authors       = ["Gary Taylor"]
  spec.email         = ["gary.taylor@hmcts.net"]

  spec.summary       = %q{A fake ACAS server for testing and development}
  spec.description   = %q{This server should look and feel like the ACAS service for employment tribunals}
  spec.homepage      = "https://github.com/ministryofjustice/et_api"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "http://mygemserver.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.executables << 'bin/fake_acas_server'
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra", '~> 2.0', '>= 2.0.1'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
