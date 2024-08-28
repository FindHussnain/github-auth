# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_08_26_122023) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "github_auth_users", force: :cascade do |t|
    t.string "github_uid"
    t.string "username"
    t.string "email"
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "github_issues", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "state"
    t.string "html_url"
    t.integer "number"
    t.bigint "github_repository_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["github_repository_id"], name: "index_github_issues_on_github_repository_id"
  end

  create_table "github_repositories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url"
    t.bigint "github_auth_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["github_auth_user_id"], name: "index_github_repositories_on_github_auth_user_id"
  end

  add_foreign_key "github_issues", "github_repositories"
  add_foreign_key "github_repositories", "github_auth_users"
end
