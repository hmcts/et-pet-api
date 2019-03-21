module PdfBuilder
  # This concern requires the Rendering and PreAllocation concerns to
  # be included in the builder service.
  #
  # Its responsibility is to provide a blob for storage which contains the filled in pdf file.
  module ActiveStorage
    extend ActiveSupport::Concern

    private

    def blob_for_pdf_file(filename)
      ::ActiveStorage::Blob.new.tap do |blob|
        blob.filename = filename
        blob.content_type = 'application/pdf'
        blob.metadata = nil
        blob.key = pre_allocated_key(filename)
        blob.upload render_to_file
      end
    end
  end
end
