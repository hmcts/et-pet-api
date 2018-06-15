require 'nokogiri'
require 'base64'
require 'active_support/core_ext/string'
module EtFakeAcasServer
  class CertificateLookupForm
    def initialize(xml, private_key_file: )
      self.xml = xml
      self.private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file))
    end

    def validate
      validate_digest
      validate_signature
    end

    def certificate_number
      parsed_values[:ec_certificate_number]
    end

    private

    def parsed_values
      @parsed_values ||= begin
        doc = Nokogiri::XML(xml)
        doc.xpath('//env:Envelope/env:Body/tns:GetECCertificate').children.inject({}) do |acc, child|
          decoded = Base64.decode64(child.text)
          decrypted = private_key.private_decrypt(decoded, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
          acc[child.name.underscore.to_sym] = decrypted
          acc
        end
      end
    end

    def validate_digest
      doc = Nokogiri::XML(xml)
      node = doc.xpath('//env:Envelope/env:Header/wsse:Security/wsu:Timestamp', doc.collect_namespaces).first
      digest_value = Base64.encode64(OpenSSL::Digest::SHA1.digest(node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0))).strip

      ns = doc.collect_namespaces
      ns['xmlns:ds'] = ns.delete('xmlns')
      provided_digest_value = doc.at_xpath('//env:Envelope/env:Header/wsse:Security/ds:Signature/ds:SignedInfo/ds:Reference/ds:DigestValue', ns).text
      if digest_value != provided_digest_value
        raise 'Wrong digest value'
      end

    end

    def validate_signature
      doc = Nokogiri::XML(xml)
      ns = doc.collect_namespaces
      ns['xmlns:ds'] = ns.delete('xmlns')
      signed_info_node = doc.at_xpath('//env:Envelope/env:Header/wsse:Security/ds:Signature/ds:SignedInfo', ns)
      signature_value_node = doc.at_xpath('//env:Envelope/env:Header/wsse:Security/ds:Signature/ds:SignatureValue', ns)
      signature_value = Base64.decode64(signature_value_node.text)
      security_token_url = doc.at_xpath('//env:Envelope/env:Header/wsse:Security/ds:Signature/ds:KeyInfo/wsse:SecurityTokenReference/wsse:Reference', ns)['URI'][1..-1]
      certificate_value = doc.at_xpath("//env:Envelope/env:Header/wsse:Security/wsse:BinarySecurityToken[@wsu:Id='#{security_token_url}']", ns).text.strip
      our_certificate = OpenSSL::X509::Certificate.new Base64.decode64(certificate_value)
      document = signed_info_node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
      unless our_certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature_value, document)
        raise 'Invalid signature'
      end

    end

    attr_accessor :xml, :private_key
  end
end
