Rails.application.routes.draw do
  get :admin_dashboard, 'admin/dashboard'
  resources :users
  resources :sessions, only: [:new, :create, :destroy]  
  get :admin_login, to: "sessions#new"
  delete :logout, to: "sessions#destroy"
  root "home#index"
end
