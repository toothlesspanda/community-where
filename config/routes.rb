Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :parties, only: [ :show ], param: :party, path: "/"
  post "/toggle_theme", to: "application#toggle", as: :toggle_theme

  resources :modal_test, only: [ :index ] do
    collection do
      get :modal
      get :modal_different_layout
      post :modal_action
    end
  end

  # Defines the root path route ("/")
  # root "home#index"
end
