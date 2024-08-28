# app/controllers/github_controller.rb
class GithubController < ApplicationController
  def import
    client = GithubClient.new(github_current_user.access_token)
    response = client.execute_query(GithubQueries::REPOSITORIES_QUERY, login: github_current_user.username)
    if response && response['data']
      repositories = response['data']['user']['repositories']['nodes']
      repositories.each do |repo_data|
        repo = GithubRepository.create!(
          name: repo_data['name'],
          description: repo_data['description'],
          url: repo_data['url'],
          github_auth_user: github_current_user
        )

        # Fetch and save issues for each repository
        issues_response = client.execute_query(
          GithubQueries::ISSUES_QUERY,
          repositoryName: repo.name,
          owner: github_current_user.username
        )
        if issues_response && issues_response['data']
          issues = issues_response['data']['repository']['issues']['nodes']
          issues.each do |issue_data|
            GithubIssue.create!(
              title: issue_data['title'],
              body: issue_data['body'],
              state: issue_data['state'],
              html_url: issue_data['url'],
              number: issue_data['number'],
              github_repository: repo
            )
          end
        end
      end
      redirect_to github_import_page_path, notice: "Repositories and Issues Imported!"
    else
      redirect_to github_import_page_path, alert: "Failed to import repositories."
    end
  end
end
