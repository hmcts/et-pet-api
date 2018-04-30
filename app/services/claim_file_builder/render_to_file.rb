module ClaimFileBuilder
  module RenderToFile
    extend ActiveSupport::Concern

    class_methods do

      def render_to_file(claim:)
        Tempfile.new.tap do |file|
          file.write render(claim)
          file.rewind
        end
      end
    end
  end
end
