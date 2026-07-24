Rails.application.routes.draw do
  devise_for :users, skip: :all

  root to: 'spa#index'

  namespace :api do
    resource :auth, only: [], controller: 'auth' do
      get :verify
      post :login
      delete :logout
      post :register
      get :confirm
      post :resend_confirmation
      post :forgot_password
      post :reset_password
    end
    resources :generation_batches, only: [:index, :create, :show] do
      resources :generation_items, only: [] do
        member do
          get :download
        end
      end
    end
    resources :image_folders, only: [:index, :show, :create, :update, :destroy] do
      resources :saved_images, only: [:create, :update, :destroy] do
        member do
          get :download
        end
      end
    end
    resources :prompt_presets, only: [:index, :create, :update, :destroy]
  end

  get '*path', to: 'spa#index', constraints: ->(req) { !req.xhr? && req.format.html? }
end
