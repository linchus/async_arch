Rails.application.routes.draw do
  # root "articles#index"

  get '/logout', to: 'oauth_session#destroy'
  get '/auth/:provider/callback', to: 'oauth_session#create'
end
