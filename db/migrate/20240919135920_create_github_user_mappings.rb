class CreateGithubUserMappings < ActiveRecord::Migration[7.1]
  def change
    create_table :github_user_mappings do |t|
      t.references :github_user, null: false, foreign_key: { to_table: :github_users }
      t.references :github_codegiant_user, null: false, foreign_key: { to_table: :github_users }
      t.references :github_project, null: false, foreign_key: { to_table: :github_projects }

      t.timestamps
    end

    # Add unique index on github_user_id and github_project_id to prevent duplicates
    add_index :github_user_mappings, [:github_user_id, :github_project_id], unique: true
  end
end
