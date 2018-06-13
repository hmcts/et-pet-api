require 'savon'
require 'base64'
require 'openssl'
require 'et_acas_api/soap_signature'
module EtAcasApi
  class AcasApiService
    attr_reader :certificate, :status

    def initialize(wsdl_url:, current_time: Time.zone.now, acas_rsa_certificate_path:, rsa_certificate_path:, rsa_private_key_path:)
      self.wsdl_url = wsdl_url
      self.current_time = current_time
      self.acas_rsa_certificate = OpenSSL::X509::Certificate.new File.read(acas_rsa_certificate_path)
      self.rsa_certificate = OpenSSL::X509::Certificate.new File.read(rsa_certificate_path)
      self.rsa_private_key = OpenSSL::PKey::RSA.new(File.read(rsa_private_key_path))
    end

    def call(id, user_id:)
      response = client.call(:get_ec_certificate, message: {
        'ECCertificateNumber' => encode_encrypt(id),
        'UserId' => encode_encrypt(user_id),
        'CurrentDateTime' => encode_encrypt(current_date_time)
      })
      raise "Error in response from ACAS" unless response.success?
      self.response_data = response.body.dig(:get_ec_certificate_response, :get_ec_certificate_result)
      set_status
      build
    end

    private

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

    def build
      return unless status == :found
      self.certificate = Certificate.new(mapped_data)
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
      aes = Base64.decode64 response_data[attr]
      decipher = aes_decipher
      decipher.update(aes) + decipher.final
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
      OpenSSL::Cipher::AES256.new(:CBC).tap do |c|
        c.decrypt
        c.key = response_key
        c.iv = response_iv
      end
    end

    def response_key
      @response_key ||= rsa_private_key.private_decrypt(Base64.decode64(response_data[:key]), OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    end

    def response_iv
      @response_iv ||= rsa_private_key.private_decrypt(Base64.decode64(response_data[:iv]), OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    end

    attr_accessor :wsdl_url, :current_time, :acas_rsa_certificate, :rsa_certificate, :rsa_private_key, :response_data
    attr_writer :certificate, :status
  end
end
