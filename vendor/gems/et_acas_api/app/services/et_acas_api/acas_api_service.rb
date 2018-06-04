require 'savon'
require 'base64'
require 'openssl'
module EtAcasApi
  class AcasApiService
    def initialize(wsdl_url:, current_time: Time.zone.now, acas_rsa_certificate_path:, rsa_certificate_path: )
      self.wsdl_url = wsdl_url
      self.current_time = current_time
      self.acas_rsa_certificate = OpenSSL::X509::Certificate.new File.read(acas_rsa_certificate_path)
      self.rsa_certificate = OpenSSL::X509::Certificate.new File.read(rsa_certificate_path)
    end

    def get_certificate(id, user_id:)
      client.call(:get_ec_certificate, message: {
        'ECCertificateNumber' => encode_encrypt(id),
        'UserId' => encode_encrypt(user_id),
        'CurrentDateTime' => encode_encrypt(current_date_time)
      })
      tmp = 1
    end

    private

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
                                   Akami::WSSE::Signature.new(
                                       Akami::WSSE::Certs.new(cert_string: rsa_certificate))

    end

    attr_accessor :wsdl_url, :current_time, :acas_rsa_certificate, :rsa_certificate
  end
end
