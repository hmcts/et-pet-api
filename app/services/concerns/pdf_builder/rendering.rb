module PdfBuilder
  # This concern is responsible for rendering the pdf with the calculated data
  #
  # It requires the  MultiTemplate module to be included
  # and the service including this must provide the data in a method
  # called pdf_fields.
  module Rendering
    extend ActiveSupport::Concern

    def initialize(source, use_xfdf: true, **kw_args)
      super(source, **kw_args)
      self.use_xfdf = use_xfdf
    end

    def builder
      opts = {
        utf8_fields: true
      }
      opts[:data_format] = 'XFdf' if use_xfdf
      @builder ||= PdfForms.new('pdftk', opts)
    end

    private

    attr_accessor :use_xfdf

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
