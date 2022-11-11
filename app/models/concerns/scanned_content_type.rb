module ScannedContentType
  extend ActiveSupport::Concern

  def auto_correct_content_type(file, scanned_content_type)
    return if Mime::Type.lookup(scanned_content_type) == Mime::Type.lookup(file.content_type)

    file.content_type = scanned_content_type
  end

  def scan_content_type(attachable)
    `file --b --mime-type '#{attachable.tempfile.path}'`.strip
  end

  class_methods do
    def scan_content_type_for(attribute)
      class_eval <<-EOS
        def #{attribute}=(attachable)
          scanned_content_type = scan_content_type(attachable)
          super(attachable).tap do
            auto_correct_content_type(#{attribute}, scanned_content_type)
          end
        end
      EOS
    end
  end
end
