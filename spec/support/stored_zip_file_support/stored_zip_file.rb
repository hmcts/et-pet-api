require 'zip'
module ETApi
  module Test
    class StoredZipFile
      def self.file_names(zip:)
        Dir.mktmpdir do |dir|
          downloaded_file_name = File.join(dir, zip.filename)
          zip.download_blob_to(downloaded_file_name)
          ::Zip::File.open(downloaded_file_name).glob('**/*').map(&:name)
        end
      end

      def self.extract(zip:, to:)
        Dir.mktmpdir do |dir|
          downloaded_file_name = File.join(dir, zip.filename)
          zip.download_blob_to(downloaded_file_name)

          ::Zip::File.open(downloaded_file_name) do |zip_file|
            zip_file.each do |entry|
              entry.extract(File.join(to, entry.name))
            end
          end
        end
      end
    end
  end
end