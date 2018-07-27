require 'rspec/expectations'

RSpec::Matchers.define(:be_a_stored_file_with_contents) do |contents|
  eq_matcher = ::RSpec::Matchers::BuiltIn::Eq.new(contents)
  match do |actual|
    actual_contents = actual.download
    actual.respond_to?(:attached?) && actual.attached? == true && eq_matcher.matches?(actual_contents)
  end

  failure_message do |actual|
    "expected that #{actual} is a stored file (currently active storage) matching the specified contents but it didn't"
  end
end
