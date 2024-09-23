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

ActiveRecord::Schema[7.1].define(version: 2024_09_23_074033) do
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

  create_table "github_codegiant_users", force: :cascade do |t|
    t.string "graphql_id"
    t.string "name"
    t.string "username"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["graphql_id"], name: "index_github_codegiant_users_on_graphql_id"
  end

  create_table "github_comments", force: :cascade do |t|
    t.bigint "github_issue_id"
    t.string "author"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["github_issue_id"], name: "index_github_comments_on_github_issue_id"
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

  create_table "github_issues_users", id: false, force: :cascade do |t|
    t.bigint "github_issue_id", null: false
    t.bigint "github_user_id", null: false
    t.index ["github_issue_id"], name: "index_github_issues_users_on_github_issue_id"
    t.index ["github_user_id"], name: "index_github_issues_users_on_github_user_id"
  end

  create_table "github_project_statuses", force: :cascade do |t|
    t.integer "github_project_id"
    t.integer "status_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "github_project_types", force: :cascade do |t|
    t.integer "github_project_id"
    t.integer "type_id"
    t.string "title"
    t.string "color"
    t.boolean "complete_trigger"
    t.integer "github_issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "github_projects", force: :cascade do |t|
    t.string "name"
    t.bigint "github_auth_user_id"
    t.integer "code_giant_project_id"
    t.string "prefix"
    t.string "codegiant_title"
    t.integer "work_space_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_giant_project_id"], name: "index_projects_on_code_giant_project_id"
    t.index ["github_auth_user_id"], name: "index_projects_on_github_auth_user_id"
    t.index ["name"], name: "index_github_projects_on_name", unique: true
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

  create_table "github_user_mappings", force: :cascade do |t|
    t.bigint "github_user_id", null: false
    t.bigint "github_codegiant_user_id", null: false
    t.bigint "github_project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["github_codegiant_user_id"], name: "index_github_user_mappings_on_github_codegiant_user_id"
    t.index ["github_project_id"], name: "index_github_user_mappings_on_github_project_id"
    t.index ["github_user_id", "github_project_id"], name: "idx_on_github_user_id_github_project_id_c825df3685", unique: true
    t.index ["github_user_id"], name: "index_github_user_mappings_on_github_user_id"
  end

  create_table "github_users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_github_users_on_username", unique: true
  end

  add_foreign_key "github_comments", "github_issues"
  add_foreign_key "github_issues", "github_repositories"
  add_foreign_key "github_repositories", "github_auth_users"
  add_foreign_key "github_user_mappings", "github_projects"
  add_foreign_key "github_user_mappings", "github_users"
  add_foreign_key "github_user_mappings", "github_users", column: "github_codegiant_user_id"
end
