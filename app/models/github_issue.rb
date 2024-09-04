class GithubIssue < ApplicationRecord
  belongs_to :github_repository

  validates :title, presence: true
end
