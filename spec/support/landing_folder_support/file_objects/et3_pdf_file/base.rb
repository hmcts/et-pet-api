require 'rspec/matchers'
require 'pdf-forms'
require_relative '../base_pdf_file'
module EtApi
  module Test
    module FileObjects
      # Represents the ET3 PDF file and provides assistance in validating its contents
      module Et3PdfFileSection
        class Base < ::EtApi::Test::FileObjects::BasePdfFile

          private

          def i18n_section
            self.class.name.demodulize.underscore.gsub(/_section\z/, '')
          end

          def mapped_field_values
            return @mapped_field_values if defined?(@mapped_field_values)
            lookup = t("response_pdf_fields.#{i18n_section}", locale: 'en')
            @mapped_field_values = lookup.inject({}) do |acc, (key, value)|
              acc[key.to_sym] = mapped_value(value, key: key)
              acc
            end
          end

          def mapped_value(value,  key:)
            if value.is_a?(Hash) && !value.key?(:field_name)
              value.inject({}) do |acc, (inner_key, inner_value)|
                acc[inner_key] = mapped_value(inner_value, key: inner_key)
                acc
              end
            else
              field_value_for(value, key: key)
            end
          end

          def field_value_for(value, key:)
            if value.key?(:select_values)
              raw = field_values[value[:field_name]]
              ret = value[:select_values].detect { |(key, v)|  v == raw }.try(:first)
              return true if ret == :true
              return false if ret == :false
              return ret.to_s if ret
              return nil if raw == value[:unselected_value]
              raise "Invalid value - '#{raw}' is not in the selected_values list or the unselected_value for field '#{key}' for section #{self.class.name}"
            else
              field_values[value[:field_name]]
            end
          end


          def date_for(date)
            return date.strftime('%d/%m/%Y') if date.is_a?(Date) || date.is_a?(Time) || date.is_a?(DateTime)
            Time.zone.parse(date).strftime('%d/%m/%Y')
          end

          def decimal_for(number)
            number.to_s
          end
        end
      end
    end
  end
end
