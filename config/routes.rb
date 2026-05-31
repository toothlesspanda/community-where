Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :markers
  resources :places do
    get "autocomplete", on: :collection
  end

  resources :marker_submissions, only: [:create]
  resources :suggestions, only: [:create]

  patch "locale", to: "locale#update", as: :locale
end
