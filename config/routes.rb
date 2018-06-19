Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post 'new-claim' => 'claims#create'
      post 'fgr-et-office' => 'fee_group_offices#create'
    end
    namespace :v2 do
      namespace :respondents do
        post "build_response" => 'build_responses#create'
      end
    end
  end
  mount EtAtosFileTransfer::Engine, at: '/atos_api'
  mount EtAcasApi::Engine => "/et_acas_api"


  get 'ping' => 'health_status/ping#show'
end
