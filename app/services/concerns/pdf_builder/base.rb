module PdfBuilder
  # This concern is used by all pdf builders
  # and provides the base functionality which is simply to receive the source data
  module Base
    extend ActiveSupport::Concern

    def initialize(source, time_zone: 'London')
      self.source = source
      self.time_zone = time_zone
    end

    included do
      private

      attr_accessor :source, :time_zone
    end
  end
end
