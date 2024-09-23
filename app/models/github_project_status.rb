# app/models/github_project_status.rb
class GithubProjectStatus < ApplicationRecord
  belongs_to :github_project
end
