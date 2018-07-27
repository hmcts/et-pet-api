require 'openssl'
require 'base64'
RSpec::Matchers.define :have_valid_encrypted_parameters_for_acas do |expected|
  include_matcher = ::RSpec::Matchers::BuiltIn::Include.new(expected.stringify_keys)
  key = File.read(File.absolute_path(File.join('..', '..', 'acas_interface_support','x509', 'theirs', 'privatekey.pem'), __dir__))
  private_key = OpenSSL::PKey::RSA.new key
  match do |actual|
    params = Hash.from_xml(actual).dig('Envelope', 'Body', 'GetECCertificate', 'request')
    params.each_pair do |k, v|
      decoded = Base64.decode64(v)
      decrypted = private_key.private_decrypt(decoded, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
      params[k] = decrypted
    end

    include_matcher.matches?(params)
  end

  failure_message do |actual|
    include_matcher.failure_message
  end
end
