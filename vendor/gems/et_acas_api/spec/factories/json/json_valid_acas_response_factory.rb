module EtAcasApi
  module Test
    class JsonResponse < OpenStruct
      def as_json(*)
        if message
          {
            error: {
              code: 'NoResponse',
              message: message
            }
          }
        elsif certificate_number
          {
            CertificateNumber: certificate_number,
            CertificateDocument: certificate_file.present? ? Base64.encode64(File.read(certificate_file)) : 'not found'
          }
        else
          nil
        end
      end
    end

    class JsonResponses < Array
      def as_json(*)
        super.compact
      end
    end
  end
end
FactoryBot.define do
  factory :json_valid_acas_responses, class: '::EtAcasApi::Test::JsonResponses' do
    transient do
      responses { [] }
      count { nil }
      traits { [] }
    end

    after(:build) do |collection, evaluator|
      if evaluator.count.nil?
        collection.concat evaluator.responses
      else
        evaluator.count.times do
          collection << build(:json_valid_acas_response, *evaluator.traits)
        end
      end
    end
  end
  factory :json_valid_acas_response, class: '::EtAcasApi::Test::JsonResponse' do
    trait :valid do
      certificate_file { File.absolute_path(File.join('.', 'pdfs', '76 EC (C) Certificate R000080.pdf'), __dir__) }
      certificate_number 'R000080/18/59'
      response_code '200'
    end

    trait :not_found do
      valid
      certificate_file nil
      response_code '200'
    end

    trait :invalid_certificate_format do
      certificate_number nil
      response_code '201'
    end

    trait :acas_server_error do
      valid
      response_code '500'
      message 'An ACAS error message'
    end
  end
end
