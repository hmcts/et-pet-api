require 'rspec/expectations'

# @TODO This should really compare a bit more intelligently - See RST-1080 item 4
RSpec::Matchers.define(:be_an_xml_file_copy_of) do |expected|
  match do |actual|
    File.size(actual) == File.size(expected)
  end

  failure_message do |actual|
    "expected that #{actual} is an xml file copy of #{expected} but the file sizes were different"
  end
end
