Rails.application.routes.draw do
  scope 'v1', defaults: { api_version: 'v1' } do
    resources :attachments, only: [:show]
  end

  scope 'v2', defaults: { api_version: 'v2' } do
    resources :comment, only: [:create]
    resources :complaint, only: [:create]
    resources :feedback, only: [:create]
    resources :enquiry, only: [:create]
  end

  get '/health', to: 'health#show'
  get '/readiness', to: 'health#readiness'
  resource :metrics, only: [:show]
end
