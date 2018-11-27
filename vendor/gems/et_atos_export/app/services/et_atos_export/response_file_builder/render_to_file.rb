module EtAtosExport
  module ResponseFileBuilder
    module RenderToFile
      extend ActiveSupport::Concern

      class_methods do

        def render_to_file(object:)
          Tempfile.new(encoding: 'windows-1252', invalid: :replace, undef: :replace, replace: '').tap do |file|
            file.write with_windows_lf(render(object))
            file.rewind
          end
        end

        def with_windows_lf(string)
          string.encode(crlf_newline: true)
        end
      end
    end
  end
end
