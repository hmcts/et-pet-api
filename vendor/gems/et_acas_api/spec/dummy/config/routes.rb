Rails.application.routes.draw do
  mount EtAcasApi::Engine => "/et_acas_api"
end
