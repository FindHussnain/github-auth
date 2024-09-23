class GithubCodegiantUser < ApplicationRecord
  validates :graphql_id, presence: true, uniqueness: true
end
