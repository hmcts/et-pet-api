module EtAcasApi
  class QueryService
    # @param [String] query
    # @param [Array] root_object
    def self.dispatch(query:, root_object:, api_version: Rails.configuration.et_acas_api.api_version, **attrs)
      query_class = "::EtAcasApi::#{query}Query".safe_constantize
      if query_class.nil?
        raise "Unknown query #{query} - Define a class called ::EtAcasApi::#{query}Command that extends ::EtAcasApi::BaseQuery"
      end
      query_class.new(api_version: api_version, **attrs).tap do |q|
        q.apply(root_object)
      end
    end
  end
end
