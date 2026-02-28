Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  post "/create_markup", to: "home#create_markup", as: :create_markup
  resources :markers
  get "locations/autocomplete"
  get "places/autocomplete"
  resources :places do
    member do
      get "places/autocomplete"
    end
  end
end
