require 'savon'
require 'base64'
require 'openssl'
require 'et_acas_api/soap_signature'
require 'mcrypt'
module EtAcasApi
  class AcasApiService
    attr_reader :status, :errors

    def initialize(wsdl_url: Rails.configuration.et_acas_api.wsdl_url,
      current_time: Time.find_zone!(Rails.configuration.et_acas_api.server_time_zone).now,
      acas_rsa_certificate_contents: Rails.configuration.et_acas_api.acas_rsa_certificate,
      rsa_certificate_contents: Rails.configuration.et_acas_api.rsa_certificate,
      rsa_private_key_contents: Rails.configuration.et_acas_api.rsa_private_key,
      logger: Rails.logger)

      self.wsdl_url = wsdl_url
      self.current_time = current_time
      self.acas_rsa_certificate = OpenSSL::X509::Certificate.new acas_rsa_certificate_contents
      self.rsa_certificate = OpenSSL::X509::Certificate.new rsa_certificate_contents
      self.rsa_private_key = OpenSSL::PKey::RSA.new(rsa_private_key_contents)
      self.logger = logger
      self.errors = {}
    end

    def call(id, user_id:, into:)
      response = client.call(:get_ec_certificate, message: {
        'request' => {
          'ins0:CurrentDateTime' => encode_encrypt(current_date_time),
          'ins0:ECCertificateNumber' => encode_encrypt(id),
          'ins0:UserId' => encode_encrypt(user_id)
        }
      })
      raise "Error in response from ACAS" unless response.success?
      self.response_data = response.body.dig(:get_ec_certificate_response, :get_ec_certificate_result)
      set_status
      add_errors
      log_errors(id: id)
      build(certificate: into)
    rescue Net::OpenTimeout => ex
      set_error_status_for(ex, id: id)
    end

    private

    def set_error_status_for(ex, id:)
      self.status = :acas_server_error
      errors[:base] ||= []
      errors[:base] << 'An error occured connecting to the ACAS service'
      logger.warn "An error occured connecting to the ACAS server when trying to find certificate '#{id}' - the error reported was '#{ex.message}'"
    end

    def set_status
      self.status = case decoded(:response_code)
                    when '200' then
                      :not_found
                    when '201' then
                      :invalid_certificate_format
                    when '500' then
                      :acas_server_error
                    else
                      :found
                    end
    end

    def add_errors
      if status == :invalid_certificate_format
        errors[:id] ||= []
        errors[:id] << 'Invalid certificate format'
      end
      if status == :acas_server_error
        errors[:base] ||= []
        errors[:base] << 'An error occured in the ACAS service'
      end
    end

    def log_errors(id:)
      if status == :acas_server_error
        logger.warn "An error occured in the ACAS server when trying to find certificate '#{id}' - the error reported was '#{decoded(:message)}'"
      end
    end

    def build(certificate:)
      return unless status == :found
      certificate.attributes = mapped_data
    end

    def mapped_data
      {
        claimant_name: decoded(:claimant_name),
        respondent_name: decoded(:respondent_name),
        date_of_issue: decoded(:date_of_issue),
        date_of_receipt: decoded(:date_of_receipt),
        certificate_number: decoded(:ec_certificate_number),
        message: decoded(:message),
        method_of_issue: decoded(:method_of_issue),
        certificate_base64: decoded(:certificate)
      }
    end

    def decoded(attr)
      aes = Base64.decode64(response_data[attr])
      aes_decipher.decrypt(aes)
    end

    def encode_encrypt(value)
      encode(encrypt(value))
    end

    def encode(value)
      Base64.encode64(value)
    end

    def encrypt(value)
      acas_rsa_certificate.public_key.public_encrypt(value, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    end

    def current_date_time
      current_time.strftime('%d/%m/%Y %H:%M:%S')
    end

    def client
      @client ||= Savon.client wsdl: wsdl_url,
        wsse_timestamp: true,
        wsse_signature:
          SoapSignature.new(
            Akami::WSSE::Certs.new(cert_string: rsa_certificate, private_key_string: rsa_private_key))

    end

    def aes_decipher
      @aes_decipher ||= Mcrypt.new(:rijndael_256, :cbc, response_key, response_iv, :pkcs7)
    end

    def response_key
      @response_key ||= Base64.decode64 \
        rsa_private_key.private_decrypt(Base64.decode64(response_data[:key]), OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    end

    def response_iv
      @response_iv ||= Base64.decode64 \
        rsa_private_key.private_decrypt(Base64.decode64(response_data[:iv]), OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    end

    attr_accessor :wsdl_url, :current_time, :acas_rsa_certificate,
      :rsa_certificate, :rsa_private_key, :response_data, :logger
    attr_writer :status, :errors
  end
end
