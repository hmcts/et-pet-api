require 'rspec/expectations'

RSpec::Matchers.define(:be_a_valid_url) do
  match do |actual|

    URI.parse(actual)
    true
  rescue URI::InvalidURIError
    false

  end

  failure_message do |actual|
    "expected that #{actual} is a valid url but it wasn't"
  end
end
