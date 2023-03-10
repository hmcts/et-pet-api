require 'rspec/expectations'

RSpec::Matchers.define(:be_a_pdf_file_containing_title) do |expected|
  match do |actual|
    unless File.file?(actual)
      @error_message = "expected that #{actual} is a pdf file containing title '#{expected}' but the file does not exist"
      next false
    end

    reader = PDF::Reader.new(actual)
    unless reader.info[:Title] =~ /#{expected}/
      @error_message = "expected that #{actual} is a pdf file containing title '#{expected}' but the title is '#{reader.info(:Title)}'"
      next false
    end
    true
  end

  failure_message do |actual|
    "expected that #{actual} is a file copy of #{expected} but the file sizes were different"
  end
end
