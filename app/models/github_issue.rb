class GithubIssue < ApplicationRecord
  belongs_to :github_repository
  has_one :github_project_type, dependent: :destroy  # Ensure type is destroyed with the issue
  validates :title, presence: true
  has_and_belongs_to_many :github_users, join_table: 'github_issues_users'
  has_many :github_comments, dependent: :destroy
end
