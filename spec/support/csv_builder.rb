module EtApi
  module Test
    module Csv
      class Builder
        attr_accessor :claimants

        def generate!
          temp_file = Tempfile.new
          CSV.open(temp_file, 'wb', row_sep: "\r\n") do |csv|
            csv << ['Title', 'First name', 'Last name', 'Date of birth', 'Building number or name', 'Street', 'Town/city', 'County', 'Postcode']
            claimants.each do |claimant|
              csv << [
                claimant.title,
                claimant.first_name,
                claimant.last_name,
                claimant.date_of_birth&.strftime('%d/%m/%Y'),
                claimant.address.building,
                claimant.address.street,
                claimant.address.locality,
                claimant.address.county,
                claimant.address.post_code
              ]
            end
          end
          temp_file.rewind

          Rack::Test::UploadedFile.new(temp_file, 'text/csv', false, original_filename: 'example-file.csv')
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
    end
  end
end
