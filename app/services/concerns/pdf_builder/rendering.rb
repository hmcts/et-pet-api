module PdfBuilder
  # This concern is responsible for rendering the pdf with the calculated data
  #
  # It requires the  MultiTemplate module to be included
  # and the service including this must provide the data in a method
  # called pdf_fields.
  module Rendering
    extend ActiveSupport::Concern

    def initialize(source, use_xfdf: true, flatten: Rails.configuration.flatten_pdf, **kw_args)
      super(source, **kw_args)
      self.use_xfdf = use_xfdf
      self.flatten = flatten
    end

    def builder
      opts = {
        utf8_fields: true
      }
      opts[:data_format] = 'XFdfEnhanced' if use_xfdf
      opts[:flatten] = true if flatten
      @builder ||= PdfForms.new('pdftk', opts)
    end

    private

    attr_accessor :use_xfdf, :flatten

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

# coding: UTF-8

require 'rexml/document'

module PdfForms
  # Map keys and values to Adobe's XFDF format.
  # This extends the standard PdfForm version which does not respect spaces in the data.
  class XFdfEnhanced < XFdf
    private

    def quote(value)
      REXML::Text.new(value.to_s, true).to_s
    end
  end
end
