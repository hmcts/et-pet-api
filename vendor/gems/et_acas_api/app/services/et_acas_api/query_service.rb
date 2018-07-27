module EtAcasApi
  class QueryService
    def self.dispatch(query:, root_object:, **attrs)
      query_class = "::EtAcasApi::#{query}Query".safe_constantize
      if query_class.nil?
        raise "Unknown query #{query} - Define a class called ::EtAcasApi::#{query}Command that extends ::EtAcasApi::BaseQuery"
      end
      query_class.new(attrs).tap do |q|
        q.apply(root_object)
      end
    end
  end
end
