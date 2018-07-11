Rails.application.routes.draw do
  mount EtAtosFileTransfer::Engine => "/atos_api"
end
