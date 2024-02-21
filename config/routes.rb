Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope 'v2', defaults: { api_version: 'v2' } do
    resources :comment, only: [:create]
    resources :complaint, only: [:create]
    resources :feedback, only: [:create]
    resources :enquiry, only: [:create]
    resources :correspondence, only: [:create]
    resources :attachments, only: [:show]
  end

  get '/health', to: 'health#show'
  get '/readiness', to: 'health#readiness'
  resource :metrics, only: [:show]
end
