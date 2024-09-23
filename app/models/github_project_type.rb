# app/models/github_project_type.rb
class GithubProjectType < ApplicationRecord
  belongs_to :github_project
  belongs_to :github_issue, optional: true
end
