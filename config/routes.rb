Rails.application.routes.draw do
  get :user_dashboard, "users/dashboard"
  resources :users 
  resources :tasks do
    member do
      get :submit_task
      get :submit_subtask
      get :approve
      get :download
    end
    collection do
      get :new_subtask
    end
  end
  resources :categories
  get :login, to: redirect("auth/google_oauth2")
  get "auth/:provider/callback", to: "omniauth_callbacks#google_oauth2"
  get "auth/failure", to: redirect("/")
  resources :sessions, only: [:new, :create, :destroy]  
  get :admin_login, to: "sessions#new"
  delete :logout, to: "sessions#destroy"
  root "home#index"
end
