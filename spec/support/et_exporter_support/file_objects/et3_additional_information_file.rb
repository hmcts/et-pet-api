require 'rspec/matchers'
require_relative './base_pdf_file'

module EtApi
  module Test
    module FileObjects
      class Et3AdditionalInformationFile < Base # rubocop:disable Metrics/ClassLength
        include RSpec::Matchers
        include EtApi::Test::I18n
        include ::RSpec::Matchers

        def path
          tempfile.path
        end
      end
    end
  end
end
