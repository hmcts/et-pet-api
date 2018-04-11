Rails.application.routes.draw do
  mount EtAtosFileTransfer::Engine => "/et_atos_file_transfer"
end
