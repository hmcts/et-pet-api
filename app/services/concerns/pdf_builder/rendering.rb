module PdfBuilder
  # This concern is responsible for rendering the pdf with the calculated data
  #
  # It requires the  MultiTemplate module to be included
  # and the service including this must provide the data in a method
  # called pdf_fields.
  module Rendering
    extend ActiveSupport::Concern

    def builder
      @builder ||= PdfForms.new('pdftk', utf8_fields: true)
    end

    private

    def render_to_file
      tempfile = Tempfile.new
      template_path = File.join(template_dir, "#{template_reference}.pdf")
      fill_in_pdf_form(template_path: template_path, to: tempfile.path, data: pdf_fields)
      tempfile
    end

    def fill_in_pdf_form(template_path:, data:, to:)
      builder.fill_form(template_path, to, data)
    end
  end
end
