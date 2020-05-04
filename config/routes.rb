
Rails.application.routes.draw do
  require "sidekiq/web"
  
  root "home#index"
  get :user_dashboard, "users/dashboard"
  
  resources :categories
  
  resources :notifications, only: [:index,:destroy] do
    member do
      get :mark_as_read
    end
    collection do
      post :mark_all_read
    end
  end
  
  resources :tasks do
    member do
      get :submit_task
      get :submit_subtask
      get :approve
      get :download
      get :notify_hr
    end
    collection do
      get :elastic_search
      get :new_subtask
      get :approved_task
      get :user_assigned_task
      get :print_task_list
      get :print_task_details
    end
  end
  
  resources :users do
    collection do
      get :print_user_list
    end
  end
  
  get :admin_login, to: "sessions#new"
  delete :logout, to: "sessions#destroy"
  
  get :login, to: redirect("auth/google_oauth2")
  get "auth/:provider/callback", to: "omniauth_callbacks#google_oauth2"
  get "auth/failure", to: redirect("/")
  
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  mount Sidekiq::Web, at: "/sidekiq"
end
