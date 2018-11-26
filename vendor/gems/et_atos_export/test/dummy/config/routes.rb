Rails.application.routes.draw do
  mount EtAtosExport::Engine => "/et_atos_export"
end
