class GithubUser < ApplicationRecord
  validates :username, presence: true, uniqueness: true
  has_and_belongs_to_many :github_issues, join_table: 'github_issues_users'
end
