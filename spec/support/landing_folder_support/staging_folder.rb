module ETApi
  module Test
    class StagingFolder
      def initialize(list_action:)
        self.list_action = list_action
      end

      def include?(filename)
        download
        process_list
        false
      end

      private

      attr_accessor :list_action

      def download
        list_action.call
      end

      def process_list
        todo
      end
    end
  end
end