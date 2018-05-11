module ClaimFileBuilder
  module RenderToFile
    extend ActiveSupport::Concern

    class_methods do

      def render_to_file(object:)
        Tempfile.new.tap do |file|
          file.write render(object)
          file.rewind
        end
      end
    end
  end
end
