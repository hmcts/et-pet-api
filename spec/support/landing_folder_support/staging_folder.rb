module ETApi
  module Test
    class StagingFolder
      def initialize(list_action:, download_action:)
        self.list_action = list_action
        self.download_action = download_action
      end

      def filenames
        list_action.call.lines.map { |line| CGI.unescape(line.strip) }
      end

      def all_unzipped_filenames
        Dir.mktmpdir do |dir|
          filenames.map do |zip_file_name|
            downloaded_file_name = File.join(dir, zip_file_name)
            download(zip_file_name, to: downloaded_file_name)
            ::Zip::File.open(downloaded_file_name).glob('**/*').map(&:name)
          end.flatten
        end
      end

      def download(zip_file, to:)
        File.open(to, 'w+') do |file|
          file.binmode
          io = download_action.call(zip_file)
          io.each do |chunk|
            file.write(chunk)
          end
          file.rewind
        end
      end

      private

      attr_accessor :list_action, :download_action
    end
  end
end
