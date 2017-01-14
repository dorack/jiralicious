# encoding: utf-8
module Jiralicious
  ##
  # Provides the interface to access the JQL search functionality.
  # Uses the same syntax as Rest interface for JQL criteria.
  #
  # [Arguments]
  # :jql            (required)    JQL string
  #
  # :start_at       (optional)    offset to start at
  #
  # :max_results    (optional)    maximum number to return
  #
  # :fields         (optional)    field options
  #
  def search(jql, options = {})
    options[:start_at] ||= 0
    options[:max_results] ||= 50
    options[:fields] = [options[:fields]] if options[:fields].is_a? String
    options[:fields] ||= ["*navigable"]

    request_body = {
      jql: jql,
      startAt: options[:start_at],
      maxResults: options[:max_results],
      fields: options[:fields]
    }.to_json

    handler = proc do |response|
      if response.code == 200 # rubocop:disable Style/GuardClause
        Jiralicious::SearchResult.new(response)
      else
        raise Jiralicious::JqlError, response["errorMessages"].join('\n')
      end
    end

    Jiralicious.session.request(
      :post,
      "#{Jiralicious.rest_path}/search",
      body: request_body,
      handler: handler
    )
  end
end
