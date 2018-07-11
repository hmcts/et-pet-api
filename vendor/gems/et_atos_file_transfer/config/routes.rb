EtAtosFileTransfer::Engine.routes.draw do
  namespace :v1 do
    get '/filetransfer/list' => 'file_transfers#index', defaults: { format: 'text' }
    post '/filetransfer/delete' => 'file_transfers#delete', defaults: { format: 'text' }
    post '/filetransfer/upload' => 'file_transfers#upload', defaults: { format: 'text' }
    get '/filetransfer/test' => 'test#show', defaults: { format: 'text' }
    get '/filetransfer/download/*filename' => 'file_transfers#download', format: false

  end

end
