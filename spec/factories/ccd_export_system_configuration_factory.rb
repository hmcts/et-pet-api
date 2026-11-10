FactoryBot.define do
  factory :ccd_export_system_configuration, class: '::EtApi::Test::Json::Node' do
    key { 'key' }
    value { 'value' }
  end
end
