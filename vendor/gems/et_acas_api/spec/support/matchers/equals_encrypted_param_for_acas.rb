require 'openssl'
require 'base64'
RSpec::Matchers.define :equals_encrypted_param_for_acas do |expected|
  key = File.read(File.absolute_path(File.join('..', '..', 'acas_interface_support','x509', 'theirs', 'privatekey.pem'), __dir__))
  private_key = OpenSSL::PKey::RSA.new key
  match do |actual|
    decoded = Base64.decode64(actual)
    decrypted = private_key.private_decrypt(decoded, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    decrypted == expected
  end
end
