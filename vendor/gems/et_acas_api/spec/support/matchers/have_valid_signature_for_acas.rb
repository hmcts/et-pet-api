require 'openssl'
require 'base64'
RSpec::Matchers.define :have_valid_signature_for_acas do |expected|
  match do |actual|
    doc = Nokogiri::XML(actual)
    ns = doc.collect_namespaces
    ns['xmlns:ds'] = ns.delete('xmlns')
    signed_info_node = doc.at_xpath('//env:Envelope/env:Header/wsse:Security/ds:Signature/ds:SignedInfo', ns)
    signature_value_node = doc.at_xpath('//env:Envelope/env:Header/wsse:Security/ds:Signature/ds:SignatureValue', ns)
    signature_value = Base64.decode64(signature_value_node.text)
    security_token_url = doc.at_xpath('//env:Envelope/env:Header/wsse:Security/ds:Signature/ds:KeyInfo/wsse:SecurityTokenReference/wsse:Reference', ns)['URI'][1..-1]
    certificate_value = doc.at_xpath("//env:Envelope/env:Header/wsse:Security/wsse:BinarySecurityToken[@wsu:Id='#{security_token_url}']", ns).text.strip
    our_certificate = OpenSSL::X509::Certificate.new Base64.decode64(certificate_value)
    document = signed_info_node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    expect(our_certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature_value, document)).to be true
  end
end
