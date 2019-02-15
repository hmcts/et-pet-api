
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "et_s3_to_azure/version"

Gem::Specification.new do |spec|
  spec.name          = "et_s3_to_azure"
  spec.version       = EtS3ToAzure::VERSION
  spec.authors       = ["Gary Taylor"]
  spec.email         = ["gary.taylor@hismessages.com"]

  spec.summary       = %q{A utility to transfer files from S3 to azure}
  spec.description   = %q{This utility has a modified, packaged up version of 'blobporter' in it from microsoft.  This allows it to be used with real azure and the emulator}
  spec.homepage      = "http://www.google.com"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
end
