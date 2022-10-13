Rails.application.routes.draw do
  resources :tasks do
    collection do
      get 'my'
      get 'shuffle'
    end
  end
  # root "articles#index"

  get '/logout', to: 'oauth_session#destroy'
  get '/auth/:provider/callback', to: 'oauth_session#create'
end
