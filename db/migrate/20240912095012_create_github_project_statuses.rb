class CreateGithubProjectStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :github_project_statuses do |t|
      t.integer :github_project_id
      t.integer :status_id
      t.string :title

      t.timestamps
    end
  end

end
