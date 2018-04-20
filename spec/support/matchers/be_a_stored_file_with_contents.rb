require 'rspec/expectations'

RSpec::Matchers.define(:be_a_stored_file_with_contents) do |contents|
  match do |actual|
    actual_contents = actual.download
    actual.respond_to?(:attached?) && actual.attached? == true && actual_contents == contents
  end

  failure_message do |actual|
    "expected that #{actual} is a stored file (currently active storage) matching the specified contents but it didn't"
  end
end
