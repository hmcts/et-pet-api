Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # namespace :api do
  namespace :v1 do
    post 'new-claim' => 'claims#create'
    post 'fgr-et-office' => 'fee_group_offices#create'
  end
end
