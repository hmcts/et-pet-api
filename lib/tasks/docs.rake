begin
  require 'rspec/core/rake_task'
  desc 'Build API request documentation from API documentation specs'
  RSpec::Core::RakeTask.new('docs:build') do |t|
    t.pattern = 'spec/documentation/**/*_spec.rb'
    t.rspec_opts = ["--format RspecApiDocumentation::ApiFormatter --exclude-pattern anything/**/*"]
  end
rescue LoadError
  puts "Documentation rake task not available in this environment"
end

