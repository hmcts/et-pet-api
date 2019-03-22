require 'rspec/matchers'
require 'pdf-forms'
module EtApi
  module Test
    module FileObjects
      # A base class for all pdf files
      class BasePdfSection
        include EtApi::Test::I18n
        include ::RSpec::Matchers

        UndefinedField = Object.new

        def initialize(field_values, lookup_root, template:)
          self.field_values = field_values
          self.template = template
          self.lookup_root = lookup_root
        end

        private

        attr_accessor :field_values, :template, :lookup_root

        def i18n_section
          self.class.name.demodulize.underscore.gsub(/_section\z/, '')
        end

        def mapped_field_values
          return @mapped_field_values if defined?(@mapped_field_values)

          lookup = t("#{lookup_root}.#{i18n_section}", locale: template)
          @mapped_field_values = lookup.inject({}) do |acc, (key, value)|
            v = mapped_value(value, key: key, path: [i18n_section])
            acc[key.to_sym] = v unless v === UndefinedField # rubocop:disable Style/CaseEquality
            acc
          end
        end

        def mapped_value(value, key:, path:)
          if value.is_a?(Hash) && !value.key?(:field_name)
            value.inject({}) do |acc, (inner_key, inner_value)|
              v = mapped_value(inner_value, key: inner_key, path: path + [key.to_s])
              acc[inner_key] = v unless v == UndefinedField
              acc
            end
          elsif value.is_a?(Hash) && value[:field_name] == false
            UndefinedField
          else
            field_value_for(value, key: key, path: path)
          end
        end

        def field_value_for(value, key:, path:)
          if value.key?(:select_values)
            raw = raw_value_from_pdf(value)
            ret = value[:select_values].detect { |(_, v)| v == raw }.try(:first)
            return ret if ret == true || ret == false
            return ret.to_s if ret
            return nil if raw == value[:unselected_value]

            raise "Invalid value - '#{raw}' is not in the selected_values list or the unselected_value for field '#{path.join('.')}.#{key}' ('#{value[:field_name]}') for section #{self.class.name}"
          else
            field_values[value[:field_name]]
          end
        end

        def raw_value_from_pdf(value)
          value[:field_name].is_a?(Array) ? value[:field_name].map { |f| field_values[f] } : field_values[value[:field_name]]
        end

        def formatted_date(date, optional: false)
          return nil if date.nil? && optional
          return date.strftime('%d/%m/%Y') if date.is_a?(Date) || date.is_a?(Time) || date.is_a?(DateTime)
          Time.zone.parse(date).strftime('%d/%m/%Y')
        end

        def decimal_for(number)
          number.to_s
        end

        def unescape(val)
          return val if val.nil?

          CGI.unescape_html(val)
        end
      end
    end
  end
end
