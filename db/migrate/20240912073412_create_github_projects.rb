class CreateGithubProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :github_projects do |t|
      t.string :name
      t.bigint :github_auth_user_id
      t.integer :code_giant_project_id
      t.string :prefix
      t.string :codegiant_title
      t.integer :work_space_id

      t.index :code_giant_project_id, name: 'index_projects_on_code_giant_project_id'
      t.index :github_auth_user_id, name: 'index_projects_on_github_auth_user_id'
      t.index :name, unique: true

      t.timestamps
    end
  end
end
