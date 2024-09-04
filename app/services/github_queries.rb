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
          }
        }
      }
    }
  GRAPHQL
end
