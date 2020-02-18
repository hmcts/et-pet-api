require 'bundler/cli'
module EtApi
  module Test
    class EtExporter
      def self.find_claim_by_reference(reference)
        job = Sidekiq::Worker.jobs.find do |job|
          job['class'] =~ /EtExporter::ExportClaimWorker/ && JSON.parse(job['args'].first).dig('resource', 'reference') == reference
        end
        raise "A claim with reference #{reference} was not exported" if job.nil?

        Claim.new(job)
      end

      class Claim
        include RSpec::Matchers

        def initialize(job)
          self.job = job
          self.data = JSON.parse(job['args'].first)
        end

        def assert_has_file(filename)
          expect(data.dig('resource', 'uploaded_files')).to include(a_hash_including('filename' => match(filename)))
        end

        def assert_has_acas_file
          assert_has_file(/\Aacas.*\.pdf\z/)
        end

        def assert_acas_file_contents
          uploaded_file = data.dig('resource', 'uploaded_files').detect { |u| u['filename'] =~ /\Aacas.*\.pdf\z/ }
          raise "No uploaded file starting with 'acas' and ending in '.pdf' has been exported" if uploaded_file.nil?

          file = download(uploaded_file)
          gem_file_path = File.join(Bundler::CLI::Common.select_spec('et_fake_acas_server').full_gem_path, 'lib', 'pdfs', '76 EC (C) Certificate R000080.pdf')
          expect(file.path).to be_a_file_copy_of(gem_file_path)
        end

        private

        attr_accessor :job, :data

        def download(uploaded_file)
          file = Tempfile.new
          file.binmode
          HTTParty.get(uploaded_file['url']) do |chunk|
            file.write(chunk)
          end
          file.rewind
          file
        end

      end
    end
  end
end
