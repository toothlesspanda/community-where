Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  constraints subdomain: "studio" do
    scope module: "studio", as: "studio" do
      root "dashboard#index"
      post "run_analysis", to: "dashboard#run_analysis"
      post "apply_proposals", to: "dashboard#apply_proposals"
      get "login", to: "sessions#new"
      post "login", to: "sessions#create"
      delete "logout", to: "sessions#destroy"

      resources :markers, only: %i[index edit update]
      resources :categories, except: %i[show]
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

  resources :markers do
    get "search", on: :collection
  end
  resources :places do
    get "autocomplete", on: :collection
  end

  resources :marker_submissions, only: [:create]
  resources :suggestions, only: [:create]

  patch "locale", to: "locale#update", as: :locale
end
