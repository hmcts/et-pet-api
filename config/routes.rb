Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v2 do
      namespace :respondents do
        post "build_response" => 'build_responses#create'
        post "repair_response" => 'repair_responses#create'
      end
      namespace :diversity do
        post "build_diversity_response" => 'build_diversity_responses#create'
      end
      namespace :references do
        post "create_reference" => 'create_references#create'
      end
      namespace :s3 do
        post 'create_signed_url' => 'signed_urls#create'
      end
      namespace :claims do
        post "build_claim" => 'build_claims#create'
        post "import_claim" => 'import_claims#create'
        post "repair_claim" => 'repair_claims#create'
        post "assign_claim" => 'assign_claims#create'
      end
      namespace :exports do
        post "export_responses" => 'export_responses#create'
        post "export_claims" => 'export_claims#create'
      end
      post "build_blob" => "build_blobs#create"
      post "create_blob" => "create_blobs#create"

      get "/blobs/:signed_id/*filename" => "blobs#show", as: :blob
      patch "/blobs/:signed_id/*filename" => "blobs#update", as: nil
      put "/blobs/:signed_id/*filename" => "blobs#update", as: nil
      post "validate" => "validation#validate"
    end
  end
  mount EtAcasApi::Engine => "/et_acas_api"

  get '/health' => 'status#healthcheck', defaults: { format: 'json' }
  get '/health/readiness' => 'status#healthcheck', defaults: { format: 'json' }
  get '/health/liveness' => 'status#healthcheck', defaults: { format: 'json' }
end
