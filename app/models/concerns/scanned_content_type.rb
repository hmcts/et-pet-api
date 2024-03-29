module ScannedContentType
  extend ActiveSupport::Concern

  def auto_correct_content_type(file, scanned_content_type)
    return if Mime::Type.lookup(scanned_content_type) == Mime::Type.lookup(file.content_type)

    file.content_type = scanned_content_type
  end

  def scan_content_type(attachable)
    path = case attachable
           when Hash then attachable[:io].path
           else attachable.tempfile.path
           end
    `file --b --mime-type '#{path}'`.strip
  end

  class_methods do
    def scan_content_type_for(attribute)
      class_eval <<-CODE, __FILE__, __LINE__ + 1 # rubocop:disable Style/DocumentDynamicEvalDefinition
        def #{attribute}=(attachable)
          scanned_content_type = scan_content_type(attachable)
          super(attachable).tap do
            auto_correct_content_type(#{attribute}, scanned_content_type)
          end
        end
      CODE
    end
  end
end
