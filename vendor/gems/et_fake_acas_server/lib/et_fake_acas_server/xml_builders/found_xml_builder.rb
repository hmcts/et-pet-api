require 'base64'
require 'openssl'
module EtFakeAcasServer
  class FoundXmlBuilder
    def initialize(form, rsa_et_certificate_path:)
      self.form = form
      self.rsa_et_certificate = OpenSSL::X509::Certificate.new File.read(rsa_et_certificate_path)
    end

    def key
      @key ||= 'testkey123456789012345678901234567890123456789012345678901234567890'
    end

    def iv
      @iv ||= 'testiv123456789012345678901234567890123456789012345678901234567890'
    end

    def builder(data)
      Nokogiri::XML::Builder.new do |xml|
        namespaces = {
            'xmlns:s' => 'http://schemas.xmlsoap.org/soap/envelope',
            'xmlns:u' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
        }
        xml['s'].Envelope(namespaces) do
          xml['s'].Header do
            xml.ActivityId("e67a4d86-e096-4a35-aa3a-2b3a8ffaaa54", 'CorrelationId': '03973d23-3c39-4359-aa69-4d37b922fb60', xmlns: 'http://schemas.microsoft.com/2004/09/ServiceModel/Diagnostics')
            xml['o'].Security('s:mustUnderstand': '1', 'xmlns:o': 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd') do
              xml['u'].Timestamp('u:Id': '_0') do
                xml['u'].Created '2014-03-03T10:15.01.251Z'
                xml['u'].Expires '2014-03-03T10:20:01.251Z'
              end
            end
          end
          xml['s'].Body do
            xml.GetECCertificateResponse(xmlns: 'https://ec.acas.org.uk/lookup/') do
              xml.GetECCertificateResult('xmlns:a': 'http://schemas.datacontract.org/2004/07/Acas.CertificateLookup.EcLookupService', 'xmlns:i': 'http://www.w3.org/2001/XMLSchema-instance') do
                xml['a'].Certificate Base64.encode64(aes_encrypt(Base64.encode64(File.read(data.certificate_file))))
                xml['a'].ClaimantName Base64.encode64(aes_encrypt(data.claimant_name))
                xml['a'].CurrentDateTime Base64.encode64(aes_encrypt(Time.now.strftime('%d/%m/%Y %H:%M:%S')))
                xml['a'].DateOfIssue Base64.encode64(aes_encrypt(data.date_of_issue.strftime('%d/%m/%Y %H:%M:%S')))
                xml['a'].DateOfReceipt Base64.encode64(aes_encrypt(data.date_of_receipt.strftime('%d/%m/%Y %H:%M:%S')))
                xml['a'].ECCertificateNumber Base64.encode64(aes_encrypt(data.certificate_number))
                xml['a'].IV Base64.encode64(rsa_encrypt(iv))
                xml['a'].Key Base64.encode64(rsa_encrypt(key))
                xml['a'].Message Base64.encode64(aes_encrypt(data.message))
                xml['a'].MethodOfIssue Base64.encode64(aes_encrypt(data.method_of_issue))
                xml['a'].RespondentName Base64.encode64(aes_encrypt(data.respondent_name))
                xml['a'].ResponseCode Base64.encode64(aes_encrypt('100'))
                xml['a'].ServiceVersion Base64.encode64(aes_encrypt('1.0'))
              end
            end
          end
        end
      end

    end

    private

    attr_accessor :rsa_et_certificate, :form

    def aes_encrypt(value)
      encrypt_cipher = build_encrypt_cipher
      encrypt_cipher.update(value) + encrypt_cipher.final
    end

    def build_encrypt_cipher
      OpenSSL::Cipher::AES256.new(:CBC).tap do |c|
        c.encrypt
        c.iv = iv
        c.key = key
      end
    end

    def rsa_encrypt(value)
      rsa_et_certificate.public_key.public_encrypt(value, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    end
  end
end
