module EtS3ToAzure
  class AzureImportCommand < Rails::Command::Base
    namespace "azure_import"

    desc "Transfer all files from S3 to azure"
    def import_files_from_s3(*args)
      require_application_and_environment!
      env = {
        S3_ACCESS_KEY: ENV.fetch('AWS_ACCESS_KEY_ID'),
        S3_SECRET_KEY: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
        ACCOUNT_NAME: ENV.fetch('AZURE_STORAGE_ACCOUNT'),
        ACCOUNT_KEY: ENV.fetch('AZURE_STORAGE_ACCESS_KEY')
      }.stringify_keys
      azure_blob_host = ENV.fetch('AZURE_STORAGE_BLOB_HOST').gsub(/\Ahttp(s?):\/\//, '')
      args = ['-f', "#{ENV.fetch('AWS_ENDPOINT')}/#{ENV.fetch('S3_UPLOAD_BUCKET')}", '-c', ENV.fetch('AZURE_STORAGE_CONTAINER'), '-t', 's3-blockblob', '-u', azure_blob_host.to_s] + args
      puts "Environment: #{env}"
      puts "Command line #{blobporter_path} #{args.join(' ')}"
      exec(env, blobporter_path, *args)
    end

    desc "Help"
    def help
      help_text_from_blobporter = `#{blobporter_path} --help 2>&1`
      puts <<-EOS
        rails azure:import_files_from_s3 OPTIONS

          This command delegates the work to 'blobporter' with certain options set according to the configuration
          for this system.  However, any further options can be passed on to the blobporter executable.  These options are :-

      EOS
      help_text_from_blobporter.lines.each do |line|
        puts "\t\t#{line}"
      end
    end

    private

    def blobporter_path
      platform = case RUBY_PLATFORM
                 when /darwin/ then :osx
                 when /linux/ then :linux
                 else
                   raise "Unknown platform #{RUBY_PLATFORM}"
                 end
      File.absolute_path("../../../../vendor/blobporter/#{platform}/blobporter", __dir__)
    end

  end
end
