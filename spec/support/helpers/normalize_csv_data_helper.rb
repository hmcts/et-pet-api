require 'csv'
module EtApi
  module Test
    module NormalizeCsvDataHelper
      def normalize_claimants_from_file(file: File.absolute_path(File.join('../../fixtures/simple_user_with_csv_group_claims.csv'), __dir__))

        block_size = 1024
        tempfile = Tempfile.new
        input_file = File.open(file, 'r')
        while true do
          chunk = input_file.read(block_size)
          break if chunk.nil?
          tempfile.write chunk.encode('utf-8', invalid: :replace, undef: :replace)
        end
        tempfile.tap(&:close)

        claimants_array = []
        CSV.foreach tempfile, headers: true do |row|
          claimants_array << {
            title: row['Title']&.downcase&.capitalize&.strip,
            first_name: row['First name']&.strip,
            last_name: row['Last name']&.strip,
            date_of_birth: Date.parse(row['Date of birth']&.strip),
            address: {
              building: row['Building number or name']&.strip,
              street: row['Street']&.strip,
              locality: row['Town/city']&.strip,
              county: row['County']&.strip,
              post_code: row['Postcode']&.strip
            }
          }
        end
        claimants_array
      end
    end
  end
end
RSpec.configure do |c|
  c.include ::EtApi::Test::NormalizeCsvDataHelper
end
