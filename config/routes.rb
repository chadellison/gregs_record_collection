Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :albums, only: [:index, :create, :update]
      resources :words, only: [:index]
      resources :artists, only: [:show]
    end
  end
end
