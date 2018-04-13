module EtAtosFileTransfer
  module V1
    class FileTransfersController < ::EtAtosFileTransfer::ApplicationController
      def index
        render locals: { files: ::ExportedFile.all }
      end

      def download
        filename = params.require(:filename)
        file = ExportedFile.find_by(filename: filename)
        temp_file = Tempfile.new(file.filename)
        file.download_blob_to(temp_file.path)
        send_file temp_file, filename: file.filename
      end
    end
  end
end