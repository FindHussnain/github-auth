Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#index" # Assuming you have a HomeController and index action
  get "/auth/:provider/callback", to: "github_sessions#create"
  get "/auth/failure", to: "github_sessions#failure"
  delete "/logout", to: "github_sessions#destroy"
  get 'github/import_page', to: 'github#import_page'
  post 'github/import', to: 'github#import'
  post 'github/fetch_issues', to: 'github#fetch_issues' # New route for selecting a repository

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
