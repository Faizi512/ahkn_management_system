Rails.application.routes.draw do
  root 'home#index'

  resources :data_uploader
  resources :voter do
    collection do
      post 'load'
      get 'search'
      post 'kid_lock'
    end
    member do
      get :lock
      get 'print'
      get :special_print
    end
  end

  # Reports
  resources :reports, only: [:index] do
    collection do
      get :attendance
      get :gender_distribution
      get :qabeela_stats
      get :urfiat_stats
      get :guest_entries
      get :daily_report
      get :welfare_status
      get :attendance_export
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
