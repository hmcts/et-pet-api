module EtAtosFileTransfer
  module V1
    class TestController < ::EtAtosFileTransfer::ApplicationController
      def show
        head :ok
      end
    end
  end
end
