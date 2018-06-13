module EtAcasApi
  module Test
    class SoapResponse < OpenStruct
      def to_xml
        aes_enc = EtAcasApi::Test::AesEncryption.new
        rsa_enc = EtAcasApi::Test::RsaEncryption.new
        builder = Nokogiri::XML::Builder.new do |xml|
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
                  xml['a'].Certificate Base64.encode64(aes_enc.encrypt_from_acas(Base64.encode64(File.read(certificate_file))))
                  xml['a'].ClaimantName Base64.encode64(aes_enc.encrypt_from_acas(claimant_name))
                  xml['a'].CurrentDateTime Base64.encode64(aes_enc.encrypt_from_acas(current_date_time.strftime('%d/%m/%Y %H:%M:%S')))
                  xml['a'].DateOfIssue Base64.encode64(aes_enc.encrypt_from_acas(date_of_issue.strftime('%d/%m/%Y %H:%M:%S')))
                  xml['a'].DateOfReceipt Base64.encode64(aes_enc.encrypt_from_acas(date_of_receipt.strftime('%d/%m/%Y %H:%M:%S')))
                  xml['a'].ECCertificateNumber Base64.encode64(aes_enc.encrypt_from_acas(certificate_number))
                  xml['a'].IV Base64.encode64(rsa_enc.encrypt_from_acas(aes_enc.iv))
                  xml['a'].Key Base64.encode64(rsa_enc.encrypt_from_acas(aes_enc.key))
                  xml['a'].Message Base64.encode64(aes_enc.encrypt_from_acas(message))
                  xml['a'].MethodOfIssue Base64.encode64(aes_enc.encrypt_from_acas(method_of_issue))
                  xml['a'].RespondentName Base64.encode64(aes_enc.encrypt_from_acas(respondent_name))
                  xml['a'].ResponseCode Base64.encode64(aes_enc.encrypt_from_acas(response_code))
                  xml['a'].ServiceVersion Base64.encode64(aes_enc.encrypt_from_acas(service_version))
                end
              end
            end
          end
        end
        builder.to_xml
      end
    end
  end
end
FactoryBot.define do
  factory :soap_valid_acas_response, class: '::EtAcasApi::Test::SoapResponse' do
    trait :valid do
      certificate_file { File.absolute_path(File.join('.', 'pdfs', '76 EC (C) Certificate R000080.pdf'), __dir__) }
      claimant_name 'The Claimant'
      current_date_time { Time.zone.now }
      date_of_issue { Time.zone.parse('3/3/2014 10:14:01') }
      date_of_receipt { Time.zone.parse('3/3/2014 10:14:31') }
      certificate_number 'R000080/18/59'
      message 'Certificate found'
      method_of_issue 'Email'
      respondent_name 'Respondent Name'
      response_code '100'
      service_version '1.0'
    end

    trait :not_found do
      valid
      response_code '200'
    end

    trait :invalid_certificate_format do
      valid
      response_code '201'
    end

    trait :acas_server_error do
      valid
      response_code '500'
    end
  end
end
