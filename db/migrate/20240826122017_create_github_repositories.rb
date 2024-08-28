class CreateGithubRepositories < ActiveRecord::Migration[7.1]
  def change
    create_table :github_repositories do |t|
      t.string :name
      t.text :description
      t.string :url
      t.references :github_auth_user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
