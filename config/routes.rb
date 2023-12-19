Rails.application.routes.draw do
  root 'home#index'

  resources :data_uploader
  resources :voter do
    collection do
      post 'load'
      get 'search'
    end
    member do
      get :lock
      get 'print'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
