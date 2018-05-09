module EtApi
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

      def extract(filename, to:)
        Dir.mktmpdir do |dir|
          full_paths = filenames.map { |f| File.join(dir, f) }
          zip = full_paths.find do |zip_file_path|
            download(File.basename(zip_file_path), to: zip_file_path)
            ::Zip::File.open(zip_file_path) { |z| z.glob('**/*').map(&:name) }.include?(filename)
          end
          return nil if zip.nil?
          extract_file_from_zip(filename, zip, to: to)
        end
      end

      def extract_to_tempfile(filename)
        Dir.mktmpdir do |dir|
          full_path = File.join(dir, filename)
          extract(filename, to: full_path)
          copy_to_temp_file(full_path)
        end
      end

      def et1_txt_file(filename)
        EtApi::Test::FileObjects::Et1TxtFile.new extract_to_tempfile(filename)
      end

      def et1a_txt_file(filename)
        EtApi::Test::FileObjects::Et1aTxtFile.new extract_to_tempfile(filename)
      end

      def tracking_new_files
        starting_filenames = filenames
        yield
        filenames - starting_filenames
      end

      def et3_txt_file(filename)
        EtApi::Test::FileObjects::Et3TxtFile.new extract_to_tempfile(filename)
      end

      private

      attr_accessor :list_action, :download_action

      def copy_to_temp_file(file_path)
        tempfile = Tempfile.new
        File.open(file_path) do |f|
          loop do
            data = f.read(4096)
            break if data.nil?
            tempfile.write data
          end
        end
        tempfile.flush
        tempfile.rewind
        tempfile
      end

      def extract_file_from_zip(filename, zip_filename, to:)
        ::Zip::File.open(zip_filename) do |z|
          z.extract(filename, to)
        end
      end
    end
  end
end
