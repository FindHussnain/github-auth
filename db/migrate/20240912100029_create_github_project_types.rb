class CreateGithubProjectTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :github_project_types do |t|
      t.integer :github_project_id
      t.integer :type_id
      t.string :title
      t.string :color
      t.boolean :complete_trigger
      t.integer :github_issue_id  # Adding the issue_id column

      t.timestamps
    end
  end
end
