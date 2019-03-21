module PdfBuilder
  # This concern is used by all pdf builders
  # and provides the base functionality which is simply to receive the source data
  module Base
    extend ActiveSupport::Concern

    def initialize(source)
      self.source = source
    end

    included do
      private

      attr_accessor :source
    end
  end
end
