require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  root "home#index"
  get "/auth/:provider/callback", to: "github_sessions#create"
  get "/auth/failure", to: "github_sessions#failure"
  delete "/logout", to: "github_sessions#destroy"
  get 'github/import_page', to: 'github#import_page'
  get 'github/edit_repo/:id', to: 'github#edit_repo', as: 'github_edit_repo'
  post 'github/create_repo/:id', to: 'github#create_repo', as: 'github_create_repo'

  post 'github/import_repos', to: 'github#import_repos'
  post 'github/fetch_issues', to: 'github#fetch_issues' # New route for selecting a repository

  get "up" => "rails/health#show", as: :rails_health_check
  get 'edit_importing_project/:project_name', to: 'github_projects#edit_importing_project', as: 'edit_importing_project'
  patch 'update_importing_project', to: 'github_projects#update_importing_project', as: 'update_importing_project'
  get 'github_codegiant_users/:project_id', to: 'github_projects#codegiant_users_page', as: 'codegiant_users_page'
  post 'update_github_issue_user', to: 'github_projects#update_github_issue_user'
end
