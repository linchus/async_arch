Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  get '/logout', to: 'oauth_session#destroy'
  get '/auth/:provider/callback', to: 'oauth_session#create'

  resources :accounts, only: %i[index show] do
    resources :statements, only: %i[index]
  end
end
