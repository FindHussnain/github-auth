class UpdateIssueUserJob < ApplicationJob
  queue_as :default

  def perform(project, token, work_space_id)
    graphql_service = GraphqlMutationService.new(token)
    # id_to_graphql_id_mapping = CodeGiantUser.where(id: code_giant_user_ids).pluck(:id, :graphql_id).to_h

    unless project.code_giant_project_id.present?
      project_info = {
        workspace_id: work_space_id,
        project_type: "kanban",
        tracking_type: "time",
        prefix: project.prefix,
        title: project.name
      }

      project_response = graphql_service.create_project(**project_info)

      if project_response.dig("createProject", "id")
        created_project_id = project_response["createProject"]["id"]
        project.update(code_giant_project_id: created_project_id)
        # Create project statuses for the project using the statuses returned in the mutation response
        project_statuses = project_response.dig("createProject", "taskStatuses")
        if project_statuses.present?
          project_statuses&.each do |status|
            GithubProjectStatus.find_or_create_by(github_project_id: project.id, status_id: status["id"]) do |project_status|
              project_status.title = status["title"]
            end
          end
        end
        project_types = project_response.dig("createProject", "taskTypes")

        if project_types.present?
          project_types&.each do |type|
            project_type = GithubProjectType.find_or_initialize_by(github_project_id: project.id, title: type["title"])
            project_type.type_id = type["id"]
            project_type.color = type["color"]
            project_type.complete_trigger = type["completeTrigger"]
            project_type.save!  # Save the record, updating if it already exists or creating a new one if it doesn't
          end
        end
      elsif project_response["errors"]
        error_messages = if project_response["errors"].is_a?(Array)
                            project_response["errors"].map { |error| error["message"] }.join(", ")
                          else
                            project_response["errors"].to_s
                          end
        Rails.logger.error "Failed to create project in CodeGiant: #{error_messages}"
        return
      else
        Rails.logger.error "Failed to create project in CodeGiant for an unknown reason."
        return
      end
    else
      created_project_id = project.code_giant_project_id
    end

    update_project_labels(project, graphql_service, work_space_id)
  end

  private

  def update_project_labels(project, graphql_service, work_space_id)
    workspace_id = work_space_id
    type_id = 2

    project_types = project.github_project_types
    # jira_aditional_types = project_types&.pluck(:title).uniq
    labels = []
    project_types.each do |type|
      labels << { id: type&.type_id&.to_s, title: type.title, color: type.color, completeTrigger: type.complete_trigger }
    end
    response = graphql_service.update_project_labels(workspace_id: workspace_id, id: project.code_giant_project_id, type_id: type_id, labels: labels)
    if response["errors"]
      Rails.logger.error "Failed to update project labels: #{response["errors"]}"
    else
      response_project_types = response["updateProjectLabels"]
      response_project_types.each do |type|
        project_type = GithubProjectType.find_or_initialize_by(github_project_id: project.id, title: type["title"])
        project_type.type_id = type["id"]
        project_type.color = type["color"]
        project_type.complete_trigger = type["completeTrigger"]
        project_type.save!  # Save the record, updating if it already exists or creating a new one if it doesn't
      end
      Rails.logger.info "Project labels updated successfully"
    end
  end
end
