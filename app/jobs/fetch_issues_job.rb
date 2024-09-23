require_dependency 'github_auth_user'
class FetchIssuesJob < ApplicationJob
  queue_as :default

  def perform(repository_id, user_id)
    user = GithubAuthUser.find(user_id)
    repository = GithubRepository.find(repository_id)
    client = GithubClient.new(user.access_token)

    issues_response = client.execute_query(
      GithubQueries::ISSUES_QUERY,
      repositoryName: repository.name,
      owner: user.username
    )

    if issues_response && issues_response['data']
      issues = issues_response.dig('data', 'repository', 'issues', 'nodes')

      if issues.present?
        issues.each do |issue_data|
          # Find or create the GitHub issue
          issue_record = repository.github_issues.find_or_create_by!(
            number: issue_data['number']
          ) do |issue|
            issue.title = issue_data['title']
            issue.body = issue_data['body']
            issue.state = issue_data['state']
            issue.html_url = issue_data['url']
            issue.created_at = issue_data['createdAt']  # GitHub creation time
            issue.updated_at = issue_data['updatedAt']  # GitHub update time
          end

          # Handle labels and create GithubProjectTypes from the labels
          labels = issue_data.dig('labels', 'nodes')

          if labels.present?
            labels.each do |label_data|
              color_with_hash = label_data['color'].start_with?('#') ? label_data['color'] : "##{label_data['color']}"

              GithubProjectType.find_or_create_by!(
                title: label_data['name'],
                color: color_with_hash,
                github_project_id: repository.id,
                github_issue_id: issue_record.id
              ) do |project_type|
                project_type.complete_trigger = false
              end
            end
          end
          # Handle assignees (Many-to-Many relationship)
          assignees = issue_data.dig('assignees', 'nodes')
          if assignees.present?
            assignees.each do |assignee_data|
              # Find or create the GitHub user (assignee)
              assignee_record = GithubUser.find_or_create_by!(username: assignee_data['login'])

              # Associate the user with the issue using the join table
              issue_record.github_users << assignee_record unless issue_record.github_users.include?(assignee_record)
            end
          end
          # Handle comments and create GithubComments
          comments = issue_data.dig('comments', 'nodes')
          if comments.present?
            comments.each do |comment_data|
              GithubComment.create!(
                github_issue_id: issue_record.id,
                author: comment_data.dig('author', 'login'),  # Author login (GitHub username)
                body: comment_data['body'],  # Comment body
                created_at: comment_data['createdAt'],  # GitHub comment creation time
                updated_at: comment_data['createdAt']  # Keep updated_at same as created_at for comments
              )
            end
          end
        end

        Rails.logger.info "Successfully fetched issues, labels, and assignees for repository: #{repository.name}"
      else
        Rails.logger.info "No issues found for repository: #{repository.name}"
      end
    else
      error_message = issues_response.dig('errors', 0, 'message') || 'Unknown error'
      Rails.logger.error "Failed to fetch issues for repository: #{repository.name}. Error: #{error_message}"
    end
  end
end
