# frozen_string_literal: true

module Api
  module V2
    class BaseController < ::ApplicationController
      helper_method :api_errors

      private

      def api_errors(command)
        command.errors.details.inject([]) do |acc, (attribute, details)|
          messages = command.errors.messages[attribute]
          details.each_with_index do |detail, idx|
            acc << json_error_for(attribute, detail, messages[idx])
          end
          acc
        end
      end

      def json_error_for(attribute, detail, message)
        {
          status: 422,
          code: detail[:error],
          title: message,
          detail: message,
          source: indexed_attribute_to_json_path(attribute),
          command: detail[:command],
          uuid: detail[:uuid]
        }
      end

      def indexed_attribute_to_json_path(attribute)
        "/#{attribute.to_s.gsub(/\[(\d*)\]/, '/\1').tr('.', '/')}"
      end

      attr_accessor :cached_root_object
    end
  end
end
