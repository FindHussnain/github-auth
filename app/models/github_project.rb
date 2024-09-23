class GithubProject < ApplicationRecord
  belongs_to :github_auth_user
  has_many :github_project_statuses, dependent: :destroy
  has_many :github_project_types, dependent: :destroy
  has_many :user_mappings, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
