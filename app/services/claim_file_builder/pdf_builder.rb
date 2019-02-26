module ClaimFileBuilder
  module PdfBuilder
    extend ActiveSupport::Concern

    def builder
      @builder ||= PdfForms.new('pdftk', utf8_fields: true)
    end

    def fill_in_pdf_form(template_path:, data:, to:)
      builder.fill_form(template_path, to, data)
    end
  end
end
