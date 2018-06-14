module EtAcasApi
  class CertificateQuery < ::EtAcasApi::BaseQuery
    def initialize(id:, user_id:, acas_api_service: AcasApiService.new)
      self.acas_api_service = acas_api_service
      self.user_id = user_id
      self.id = id
    end

    def apply(root_object)
      acas_api_service.call(id, user_id: user_id, into: root_object)
    end

    def status
      acas_api_service.status
    end

    def valid?
      status == :found
    end

    def errors
      acas_api_service.errors
    end

    private

    attr_accessor :acas_api_service, :user_id, :id
  end
end
