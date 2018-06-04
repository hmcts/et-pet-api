module EtAcasApi
  class CertificateQuery < ::EtAcasApi::BaseQuery
    def initialize(id:)

    end

    def apply(root_object)
      response = AcasApiService.new.get_certificate
      boom!
    end

    def status
      :found
    end
  end
end
