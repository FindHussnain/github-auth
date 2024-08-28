class CreateGithubIssues < ActiveRecord::Migration[7.1]
  def change
    create_table :github_issues do |t|
      t.string :title
      t.text :body
      t.string :state
      t.string :html_url
      t.integer :number
      t.references :github_repository, null: false, foreign_key: true

      t.timestamps
    end
  end
end
