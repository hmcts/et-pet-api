require 'rspec/expectations'

RSpec::Matchers.define(:be_a_file_copy_of) do |expected|
  match do |actual|
    File.size(actual) == File.size(expected)
  end

  failure_message do |actual|
    "expected that #{actual} is a file copy of #{expected} but the file sizes were different"
  end
end
