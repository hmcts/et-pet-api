module Api
  module V2
    class BlobsController < ::ApplicationController
      include ActiveStorage::SetBlob
      include ActiveStorage::Streaming
      before_action :reject_not_uploaded, only: [:show]

      def show
        if request.headers["Range"].present?
          send_blob_byte_range_data @blob, request.headers["Range"]
        else
          http_cache_forever public: true do
            response.headers["Accept-Ranges"] = "bytes"
            response.headers["Content-Length"] = @blob.byte_size.to_s

            send_blob_stream @blob, disposition: params[:disposition]
          end
        end
      end

      private

      def reject_not_uploaded
        return unless @blob.metadata[:uploaded] == false

        head :not_found
      end
    end
  end
end
