require 'rspec/expectations'

RSpec::Matchers.define(:be_a_stored_file) do
  match do |actual|
    actual.respond_to?(:attached?) && actual.attached? == true
  end

  failure_message do |actual|
    "expected that #{actual} is a stored file (currently active storage) which means it should respond to :attached? but it didn't"
  end
end
