module EtAcasApi
  module Test
    class RsaEncryption
      def initialize(acas_rsa_certificate_path: File.absolute_path(File.join('..', 'acas_interface_support', 'x509', 'theirs', 'publickey.cer'), __dir__),
                     acas_rsa_private_key_path: File.absolute_path(File.join('..', 'acas_interface_support', 'x509', 'theirs', 'privatekey.pem'), __dir__),
                     rsa_certificate_path: File.absolute_path(File.join('..', 'acas_interface_support', 'x509', 'ours', 'publickey.cer'), __dir__),
                     rsa_private_key_path: File.absolute_path(File.join('..', 'acas_interface_support', 'x509', 'ours', 'privatekey.pem'), __dir__))
        self.acas_rsa_certificate = OpenSSL::X509::Certificate.new File.read(acas_rsa_certificate_path)
        self.acas_rsa_private_key = OpenSSL::PKey::RSA.new(File.read(acas_rsa_private_key_path))
        self.rsa_certificate = OpenSSL::X509::Certificate.new File.read(rsa_certificate_path)
        self.rsa_private_key = OpenSSL::PKey::RSA.new(File.read(rsa_private_key_path))

      end
      def encrypt_from_acas(value)
        rsa_certificate.public_key.public_encrypt(value, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
      end

      private

      attr_accessor :acas_rsa_certificate, :acas_rsa_private_key, :rsa_certificate, :rsa_private_key
    end
  end
end
