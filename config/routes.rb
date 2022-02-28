Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope 'v1' do
    resources :complaint, only: [:create]
    resources :attachments, only: [:show]
    resources :correspondence, only: [:create]
  end

  get '/health', to: 'health#show'
  get '/readiness', to: 'health#readiness'
  resource :metrics, only: [:show]
end
