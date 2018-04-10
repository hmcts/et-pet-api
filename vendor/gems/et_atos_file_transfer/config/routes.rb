EtAtosFileTransfer::Engine.routes.draw do
  namespace :v1 do
    get '/filetransfer/list' => 'file_transfers#index', defaults: { format: 'text' }
    get '/filetransfer/download/*filename' => 'file_transfers#download', format: false
  end

end
