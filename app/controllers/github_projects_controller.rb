class GithubProjectsController < ApplicationController
  before_action :authenticate_user!, only: %i[edit_importing_project update_importing_project]

  def edit_importing_project
    @project = GithubProject.find_by(name: params[:project_name])
  end

  def update_importing_project
    @project = GithubProject.find_by(name: params[:github_project][:project_name])
    @project.update(prefix: params[:github_project][:prefix])
    # @project.update(codegiant_title: params[:project][:codegiant_title], prefix: params[:project][:prefix])
    flash[:notice] = 'Project was updated successfully.'
    UpdateIssueUserJob.perform_now(@project, ENV['TOKEN'], 7489)
    redirect_to codegiant_users_page_path(@project)
  end

  def codegiant_users_page
    @githug_users = GithubUser.all
    @codegiant_users = GithubCodegiantUser.all
  end

  def update_github_issue_user
    project_id = params[:id]
    github_user_ids = params[:github_user_ids]
    code_giant_user_ids = params[:code_giant_user_ids]

    if github_user_ids.present?
      # Iterate through github_user_ids array and update/create records
      github_user_ids.each_with_index do |github_user_id, index|
        code_giant_user_id = code_giant_user_ids[index]

        # Proceed only if both IDs are present
        if github_user_id.present? && code_giant_user_id.present?
          # Find or create user mapping record
          user_mapping = GithubUserMapping.find_or_initialize_by(github_user_id: github_user_id, github_project_id: project_id)
          user_mapping.update(github_codegiant_user_id: code_giant_user_id)
        end
      end

      flash[:success] = "User mappings updated successfully."
    else
      flash[:error] = "No user mappings provided."
    end

    redirect_to root_path  # Redirect to a relevant path after updating mappings
  end

  private

  def authenticate_user!
    unless session[:github_user_id]
      flash[:alert] = "You must be logged in to access this page."
      redirect_to root_path
    end
  end
end
