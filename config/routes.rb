Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  constraints subdomain: "studio" do
    scope module: "studio", as: "studio" do
      root "dashboard#index"
      post "run_analysis", to: "dashboard#run_analysis"
      get "login", to: "sessions#new"
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"

      resources :submissions, only: %i[index show]
      resources :suggestions, only: %i[index]
      resources :proposals, only: %i[index show update] do
        member do
          patch :approve
          patch :reject
          post :execute
        end
      end
    end

    authenticate = ->(request) { request.session[:studio_authenticated] }
    constraints authenticate do
      mount MissionControl::Jobs::Engine, at: "/jobs"
    end
  end

  root "home#index"

  resources :markers
  resources :places do
    get "autocomplete", on: :collection
  end

  resources :marker_submissions, only: [:create]
  resources :suggestions, only: [:create]

  patch "locale", to: "locale#update", as: :locale
end
