FactoryBot.define do
  factory :claimants_file, class: 'EtApi::Test::Csv::Builder' do
    claimants { [] }
  end
end
