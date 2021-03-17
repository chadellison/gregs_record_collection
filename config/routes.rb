Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :albums, only: [:index, :update]
      resources :words, only: [:index]
    end
  end
end
