require_dependency 'github_auth_user'

class FetchAssigneesJob < ApplicationJob
  queue_as :default

  def perform(repository_id, user_id)
    user = GithubAuthUser.find(user_id)
    repository = GithubRepository.find(repository_id)
    client = GithubClient.new(user.access_token)

    assignees_response = client.execute_query(
      GithubQueries::ASSIGNEES_QUERY,
      repositoryName: repository.name,
      owner: user.username
    )

    if assignees_response && assignees_response['data']
      issues = assignees_response.dig('data', 'repository', 'issues', 'nodes')

      if issues.present?
        issues.each do |issue_data|
          # Fetch all assignees for the current issue
          assignees = issue_data.dig('assignees', 'nodes')

          if assignees.present?
            assignees.each do |assignee_data|
              # Find or create the GitHub user by their login (username)
              GithubUser.find_or_create_by!(username: assignee_data['login'])
            end
          end
        end
        Rails.logger.info "Successfully fetched assignees for repository: #{repository.name}"
      else
        Rails.logger.info "No issues or assignees found for repository: #{repository.name}"
      end
    else
      Rails.logger.error "Failed to fetch assignees for repository: #{repository.name}"
    end
  end
end
