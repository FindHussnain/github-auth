# app/models/comment.rb
class GithubComment < ApplicationRecord
  belongs_to :github_issue
end
