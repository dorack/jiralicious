# encoding: utf-8
module Jiralicious
  def search(jql, options = {})
    options[:start_at] ||= 0
    options[:max_results] ||= 50

    request_body = {
      :jql => jql,
      :startAt => options[:start_at],
      :maxResults => options[:max_results]
    }.to_json

    handler = Proc.new do |response|
      if response.code == 200
        Jiralicious::SearchResult.new(response)
      else
        raise Jiralicious::JqlError.new(response['errorMessages'].join('\n'))
      end
    end

    Jiralicious.session.request(
      :post,
      "#{Jiralicious.rest_path}/search",
      :body => request_body,
      :handler => handler
    )
  end
end
