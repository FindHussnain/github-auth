# app/services/github_client.rb
require 'rest-client'
require 'json'

class GithubClient
  GITHUB_API_ENDPOINT = "https://api.github.com/graphql"

  def initialize(access_token)
    @access_token = access_token
  end

  def execute_query(query, variables = {})
    payload = {
      query: query,
      variables: variables
    }.to_json

    headers = {
      Authorization: "Bearer #{@access_token}",
      content_type: :json,
      accept: :json
    }

    response = RestClient.post(GITHUB_API_ENDPOINT, payload, headers)
    JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error "GraphQL request failed: #{e.response}"
    nil
  end
end
