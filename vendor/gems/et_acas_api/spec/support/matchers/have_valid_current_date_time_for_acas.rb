require 'openssl'
require 'base64'
RSpec::Matchers.define :have_valid_current_date_time_for_acas do |expected|
  match do |actual|
    key = File.read(File.absolute_path(File.join('..', '..', 'acas_interface_support','x509', 'theirs', 'privatekey.pem'), __dir__))
    private_key = OpenSSL::PKey::RSA.new key

    encrypted = Base64.decode64(Hash.from_xml(actual).dig('Envelope', 'Body', 'GetECCertificate', 'CurrentDateTime'))
    decrypted = private_key.private_decrypt(encrypted, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)
    actual_date = Time.zone.parse(decrypted)
    now = Time.zone.now
    expect(actual_date.to_f).to be_within(1.0).of(now.to_f)
  end
end
