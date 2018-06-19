module EtAcasApi
  class CertificateQuery < ::EtAcasApi::BaseQuery
    attr_reader :errors, :status

    def initialize(id:, user_id:, acas_api_service: AcasApiService.new)
      self.acas_api_service = acas_api_service
      self.user_id = user_id
      self.id = id
      self.errors = {}
    end

    def apply(root_object)
      return unless valid?
      acas_api_service.call(id, user_id: user_id, into: root_object)
      add_errors
      set_status
    end

    def valid?
      validate_user_id
      validate_id
      errors.empty?
    end

    private

    def set_status
      self.status = acas_api_service.status
    end

    def add_errors
      errors.merge! acas_api_service.errors unless acas_api_service.status == :found
    end

    def validate_id
      return if id =~/\A(R|NE|MU)\d{6}\/\d{2}\/\d{2}/
      errors[:id] ||= []
      errors[:id] << 'Invalid certificate format'
      self.status = :invalid_certificate_format
    end

    def validate_user_id
      return unless user_id.nil?
      errors[:user_id] ||= []
      errors[:user_id] << "Missing user id"
      self.status = :invalid_user_id
    end

    attr_accessor :acas_api_service, :user_id, :id
    attr_writer :errors, :status
  end
end
