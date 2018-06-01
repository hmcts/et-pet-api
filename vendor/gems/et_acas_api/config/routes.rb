EtAcasApi::Engine.routes.draw do
  get '/certificates/*id' => 'certificates#show'
end
