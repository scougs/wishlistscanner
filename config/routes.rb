Rails.application.routes.draw do

# Devise Routes
  devise_for :users, controllers: {registrations: 'registrations'}

# Root URL
  root 'users#index'

# Routes for Users
  resources :users
  get 'dashboard', to: 'users#dashboard'

# Routes for Wishlists
  resources :wishlists do
    member do
      get 'run_scan', to: 'wishlists#run_scan', as: :run_scan
    end
  end
end
