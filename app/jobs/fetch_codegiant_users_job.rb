class FetchCodegiantUsersJob < ApplicationJob
  queue_as :default

  def perform()
    users_data = GraphqlService.query["data"]["me"]["workspaces"].flat_map do |workspace|
      workspace["projects"].flat_map do |project|
        project["collaborators"]["nodes"] if project["collaborators"].present?
      end
    end.compact

    users_data.each do |user_data|
      user = user_data["user"]
      user_attributes = {
        name: user["name"],
        username: user["username"],
        email: user["email"].presence || user["publicEmail"]
      }
      cgu = GithubCodegiantUser.find_or_initialize_by(graphql_id: user["id"])
      cgu.assign_attributes(user_attributes)
      cgu.save!
    end
    Rails.logger.info("CodeGiant users fetched and saved successfully.")
  end
end
