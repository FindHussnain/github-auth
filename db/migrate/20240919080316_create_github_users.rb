class CreateGithubUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :github_users do |t|
      t.string :username

      t.timestamps
    end

    # Add the unique index inside the `change` method
    add_index :github_users, :username, unique: true
  end
end
