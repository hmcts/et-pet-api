module EtApi
  module Test
    module Json
      class Node < OpenStruct
        def as_json(*)
          to_h.inject({}) do |acc, (k, v)|
            acc[k] = normalize(v)
            acc
          end
        end

        private

        def normalize(value)
          case value
          when Node then value.as_json
          when Array then value.map { |i| normalize(i) }
          else value
          end
        end
      end

      class Document < Node

      end
    end

  end
end
