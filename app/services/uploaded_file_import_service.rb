module UploadedFileImportService
  def self.import_file_url(url, into: UploadedFile.new, autosave: true)
    return if url.nil?

    file = Tempfile.new
    file.binmode
    response = HTTParty.get(url, stream_body: true) do |chunk|
      file.write chunk
    end
    file.flush
    into.file = ActionDispatch::Http::UploadedFile.new filename: into.filename || File.basename(url),
                                                       tempfile: file,
                                                       type: response.content_type
    into.save if autosave
    into
  end

  def self.import_from_key(key, into: UploadedFile.new, logger: Rails.logger, autosave: true)
    return if key.nil?

    adapter = Azure.new(into, logger: logger)
    adapter.import_from_key(key)
    into.save if autosave
    into
  end

  class Azure
    def initialize(model, logger:)
      self.model = model
      self.logger = logger
      self.timings = {}
    end

    def import_from_key(key)
      timings.clear
      blob = ActiveStorage::Blob.new(blob_attributes_for(key))
      copy_blob(blob, key)
      delete_source_blob(key)
      model.file.attach blob
      log_import_from_key(key)
    end

    private

    def info(*args)
      logger.tagged("UploadedFileImportService::Azure") { logger.info(*args) }
    end

    def log_import_from_key(key)
      total = timings.values.sum
      info "File #{key} imported from direct upload container in #{total}ms (Download: #{timings[:download]}ms, Upload #{timings[:upload]}ms, Delete #{timings[:delete]}ms)"
    end

    def measure(&block)
      Benchmark.ms(&block).round(1)
    end

    def delete_source_blob(key)
      timings[:delete_source] = measure do
        direct_upload_service.blobs.delete_blob(direct_upload_service.container, key)
      end
    end

    def copy_blob(blob, key)
      tempfile = download_to_tempfile(key)
      upload_from_tempfile(blob, tempfile)
      tempfile.delete
    end

    def upload_from_tempfile(blob, tempfile)
      timings[:upload] = measure do
        blob.upload(tempfile)
      end
    end

    def download_to_tempfile(key)
      tempfile = Tempfile.new
      tempfile.binmode
      timings[:download] = measure do
        direct_upload_service.download(key) { |chunk| tempfile.write(chunk) }
      end
      tempfile.rewind
      tempfile
    end

    def source_uri_for(blob, key)
      direct_upload_service.url key, expires_in: 1.day, filename: blob.filename, content_type: blob.content_type, disposition: :inline
    end

    attr_accessor :model, :timings, :logger

    def blob_attributes_for(value)
      props = direct_upload_service.blobs.get_blob_properties(direct_upload_service.container, value)
      { filename: model.filename,
        byte_size: props.properties[:content_length],
        checksum: props.properties[:content_md5],
        content_type: props.properties[:content_type],
        metadata: {} }
    end

    def direct_upload_service
      config = Rails.configuration.active_storage
      @direct_upload_service ||= ActiveStorage::Service.configure :"#{config.service}_direct_upload", config.service_configurations
    end
  end

end
