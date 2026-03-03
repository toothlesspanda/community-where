Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :markers
  resources :places
  get "places/autocomplete"

  resources :marker_submissions, only: [:create]
end
