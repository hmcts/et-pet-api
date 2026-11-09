
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "et_ccd_export/version"

Gem::Specification.new do |spec|
  spec.name          = "et_ccd_export"
  spec.version       = EtCcdExport::Version
  spec.authors       = ["Gary Taylor"]
  spec.email         = ["gary.taylor@hmcts.net"]

  spec.summary       = %q{Interim gem for ccd exports for employment tribunals}
  spec.description   = %q{Interim gem for ccd exports for employment tribunals}
  spec.homepage      = "https://github.com/hmcts/et_ccd_export"
  spec.license       = "MIT"

  # Path gems are also loaded at runtime, when Git may not be installed.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    Dir["{app,config,db,lib}/**/*", "README.md", "Rakefile"].select { |f| File.file?(f) }
  end
  spec.require_paths = ["lib"]
end
