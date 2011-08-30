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

    response = Jiralicious.session.perform_request do
      Jiralicious::Session.post(
                                "#{Jiralicious.rest_path}/search",
                                :body => request_body
                                )
    end

    if response.code == 200
      response = JSON.parse(response.body)
    else
      raise Jiralicious::JqlError
    end
  end
end
