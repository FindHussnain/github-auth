class CreateGithubComments < ActiveRecord::Migration[7.1]
  def change
    create_table :github_comments do |t|
      t.references :github_issue, index: true  # This creates the foreign key column and an index
      t.string :author
      t.text :body
      t.timestamps  # Adds created_at and updated_at
    end

    add_foreign_key :github_comments, :github_issues  # This adds the foreign key constraint
  end
end
