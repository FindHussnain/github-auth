class CreateJoinTableGithubIssuesGithubUsers < ActiveRecord::Migration[7.1]
  def change
    create_join_table :github_issues, :github_users do |t|
      t.index :github_issue_id
      t.index :github_user_id
    end
  end
end
