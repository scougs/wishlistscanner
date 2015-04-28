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
      get 'manual_send_email', to: 'wishlists#manual_send_update_email', as: :manual_send_update_email
    end
  end

# Contact Form Routes
  match '/contacts', to: 'contacts#new', via: 'get'
  resources "contacts", only: [:new, :create]

end
