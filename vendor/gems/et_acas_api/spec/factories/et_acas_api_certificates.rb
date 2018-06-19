FactoryBot.define do
  factory :et_acas_api_certificate, class: 'EtAcasApi::Certificate' do
    number "MyString"
    claimant_name "MyString"
    respondent_name "MyString"
    date_of_receipt "2018-06-01 10:04:16"
    date_of_issue "2018-06-01 10:04:16"
    method_of_issue "MyString"
  end
end
