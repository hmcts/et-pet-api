require 'openssl'
require 'base64'
RSpec::Matchers.define :have_valid_current_date_time_for_acas do |expected|
  sub_matcher = ::RSpec::Matchers::BuiltIn::BeWithin.new(10.seconds).of(Time.now)
  match do |actual|
    key = File.read(File.absolute_path(File.join('..', '..', 'acas_interface_support','x509', 'theirs', 'privatekey.pem'), __dir__))
    private_key = OpenSSL::PKey::RSA.new key

    encrypted = Base64.decode64(Hash.from_xml(actual).dig('Envelope', 'Body', 'GetECCertificate', 'request', 'CurrentDateTime'))
    decrypted = private_key.private_decrypt(encrypted, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    actual_date = Time.parse(decrypted)
    sub_matcher.matches?(actual_date)
  end

  failure_message do |actual|
    sub_matcher.failure_message
  end
end
