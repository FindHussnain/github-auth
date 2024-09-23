# app/services/github_queries.rb
module GithubQueries
  REPOSITORIES_QUERY = <<-GRAPHQL
    query($login: String!) {
      user(login: $login) {
        repositories(first: 100) {
          nodes {
            name
            description
            url
          }
        }
      }
    }
  GRAPHQL

  ISSUES_QUERY = <<-GRAPHQL
    query($repositoryName: String!, $owner: String!) {
      repository(name: $repositoryName, owner: $owner) {
        issues(first: 100) {
          nodes {
            title
            body
            state
            url
            number
            createdAt  # Issue creation time
            updatedAt  # Last update time
            labels(first: 100) {   # Fetching labels
              nodes {
                name
                color
              }
            }
            assignees(first: 100) {  # Fetching assignees
              nodes {
                login  # Fetching the GitHub username (login) of each assignee
              }
            }
            comments(first: 100) {  # Fetching comments for the issue
              nodes {
                body       # The content of the comment
                createdAt  # When the comment was created
                author {
                  login   # GitHub username of the comment's author
                }
              }
            }
          }
        }
      }
    }
  GRAPHQL

  ASSIGNEES_QUERY = <<-GRAPHQL
    query($repositoryName: String!, $owner: String!) {
      repository(name: $repositoryName, owner: $owner) {
        issues(first: 100) {
          nodes {
            title
            assignees(first: 100) {
              nodes {
                login   # Fetching only the login (username) of assignees
              }
            }
          }
        }
      }
    }
  GRAPHQL

end
