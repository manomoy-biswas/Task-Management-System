Rails.application.routes.draw do
  get :user_dashboard, "users/dashboard"
  get :task_assigned_by_me, "tasks/assigned_by_me"
  get :task_approved, "tasks/approved_task"
  resources :users 
  resources :tasks do
    member do
      get :submit_task
      get :submit_subtask
      get :approve
      get :download
      get :notify_hr
    end
    collection do
      get :new_subtask
    end
  end
  resources :categories
  resources :notifications, only: [:index] do
    member do
      get :mark_as_read
    end
    collection do
      post :mark_all_read
    end
  end
  get :login, to: redirect("auth/google_oauth2")
  get "auth/:provider/callback", to: "omniauth_callbacks#google_oauth2"
  get "auth/failure", to: redirect("/")
  resources :sessions, only: [:new, :create, :destroy]  
  get :admin_login, to: "sessions#new"
  delete :logout, to: "sessions#destroy"
  root "home#index"
end
