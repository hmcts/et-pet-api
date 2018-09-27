require 'rspec/expectations'

RSpec::Matchers.define(:have_file_encoding) do |expected|
  actual_file_encoding = nil
  match do |actual|
    actual_file_encoding = `file --mime-encoding #{actual}`.match(/: (\S*)/)[1]
    actual_file_encoding == expected
  end

  failure_message do |actual|
    "expected that #{actual} is a encoded with #{expected} but it was encoded with #{actual_file_encoding}"
  end
end
