# app/controllers/github_controller.rb
class GithubController < ApplicationController
  def import_page; end

  def import
    binding.pry
    service = GithubImportService.new(github_current_user)
    service.fetch_repositories
    redirect_to github_import_page_path, notice: "Repositories Imported!"
  end
end
