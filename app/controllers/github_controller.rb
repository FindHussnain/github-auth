class GithubController < ApplicationController
  def import_page
    @repositories = github_current_user&.github_repositories
  end

  def import_repos
    unless github_current_user
      redirect_to root_path, alert: "Authenticate first to continue."
      return
    end
    client = GithubClient.new(github_current_user.access_token)
    response = client.execute_query(GithubQueries::REPOSITORIES_QUERY, login: github_current_user.username)

    if response && response['data']
      repositories = response['data']['user']['repositories']['nodes']
      repositories.each do |repo_data|
        repo = github_current_user.github_repositories.find_or_create_by!(
          name: repo_data['name'],
          github_auth_user: github_current_user
        ) do |repo|
          repo.description = repo_data['description']
          repo.url = repo_data['url']
        end
        GithubProject.find_or_create_by!(name: repo_data['name'], github_auth_user: github_current_user) do |project|
          project.prefix = ''
        end
        FetchAssigneesJob.perform_now(repo.id, github_current_user.id)
      end

      redirect_to github_import_page_path, notice: "Repositories and Issues Imported!"
    else
      redirect_to github_import_page_path, alert: "Failed to import repositories."
    end
  end

  def fetch_issues
    repo = GithubRepository.find(params[:repository_id])

    FetchIssuesJob.perform_later(repo.id, github_current_user.id) # Run in background
    redirect_to github_edit_repo_path(repo), notice: "Fetching issues for repository #{repo.name}. This may take a few minutes."
  end

  def edit_repo
    @repository = GithubRepository.find(params[:id])
  end

  def create_repo
    repository = GithubRepository.find_by(id: params[:id]) # This fetches the existing repository in your system
    token = ENV['TOKEN']
    service = GraphqlMutationService.new(token)

    # Use the name from the form (user-provided) instead of the stored repository name
    user_provided_name = params[:github_repository][:name]

    response = service.create_repository(
      workspace_id: "7489",
      title: user_provided_name, # Use the name from the form input here
      description: repository.description, # You can still use other attributes from the existing repository
      import_url: repository.url,
      import_url_username: github_current_user.username
    )

    # Handle response or errors
    if response["errors"]
      flash[:error] = "Error creating repository: #{response['errors']}"
      redirect_to root_path
    else
      flash[:notice] = "Repository created successfully!"
      FetchCodegiantUsersJob.perform_now()
      redirect_to edit_importing_project_path(repository.name)
    end

  end
end
