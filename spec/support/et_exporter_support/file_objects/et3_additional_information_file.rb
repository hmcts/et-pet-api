require 'rspec/matchers'
require_relative 'base_pdf_file'

module EtApi
  module Test
    module FileObjects
      class Et3AdditionalInformationFile < Base
        include RSpec::Matchers
        include EtApi::Test::I18n
        include ::RSpec::Matchers

        delegate :path, to: :tempfile
      end
    end
  end
end
