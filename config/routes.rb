Rails.application.routes.draw do
  devise_for :users
  
  root 'terms#index'

  resources :terms, only: %i(index new create destroy show update)

  get 'pages/about' => 'pages#about'

  get 'api/v1/terms/description.json' => 'terms#description'
end
