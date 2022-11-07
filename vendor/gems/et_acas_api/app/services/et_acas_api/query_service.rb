module EtAcasApi
  class QueryService
    # @param [String] query
    # @param [Array] root_object
    # @return [EtAcasApi::CertificateQuery] The query result
    def self.dispatch(query:, root_object:, api_version: Rails.configuration.et_acas_api.api_version, acas_api_service: "::EtAcasApi::V#{api_version}::AcasApiService".constantize, **attrs)
      query_class = "::EtAcasApi::#{query}Query".safe_constantize
      if query_class.nil?
        raise "Unknown query #{query} - Define a class called ::EtAcasApi::#{query}Command that extends ::EtAcasApi::BaseQuery"
      end
      query_class.new(acas_api_service: acas_api_service.new, **attrs).tap do |q|
        q.apply(root_object)
      end
    end

    def self.supports_multi?(api_version: Rails.configuration.et_acas_api.api_version, acas_api_service: "::EtAcasApi::V#{api_version}::AcasApiService".constantize)
      acas_api_service.supports_multi?
    end
  end
end
