module EtApi
  module Test
    class StagingFolder
      def initialize(url:, username:, password:)
        self.base_url = url
        self.username = username
        self.password = password
      end

      def empty?
        filenames.empty?
      end

      def filenames
        resp = HTTParty.get("#{base_url}/list", basic_auth: { username: username, password: password })
        resp.body.lines.map { |line| CGI.unescape(line.strip) }
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
          HTTParty.get("#{base_url}/download/#{zip_file}", basic_auth: { username: username, password: password }) do |chunk|
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
        Tempfile.new.tap { |tempfile| extract(filename, to: tempfile.path) }
      end

      def et1_txt_file(filename)
        EtApi::Test::FileObjects::Et1TxtFile.new extract_to_tempfile(filename)
      end

      def et1a_txt_file(filename)
        EtApi::Test::FileObjects::Et1aTxtFile.new extract_to_tempfile(filename)
      end

      def et3_txt_file(filename)
        EtApi::Test::FileObjects::Et3TxtFile.new extract_to_tempfile(filename)
      end

      def et3_pdf_file(filename, template: 'et3-v1-en')
        EtApi::Test::FileObjects::Et3PdfFile.new extract_to_tempfile(filename), template: template, lookup_root: 'response_pdf_fields'
      end

      def et1_pdf_file(filename, template: 'et1-v1-en')
        EtApi::Test::FileObjects::Et1PdfFile.new extract_to_tempfile(filename), template: template, lookup_root: 'claim_pdf_fields'
      end

      private

      attr_accessor :base_url, :username, :password

      def extract_file_from_zip(filename, zip_filename, to:)
        ::Zip::File.open(zip_filename) do |z|
          z.extract(filename, to) { true }
        end
      end
    end
  end
end
