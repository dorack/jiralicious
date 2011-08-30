# encoding: utf-8
module Jiralicious
  def search(jql, options = {})
    options[:start_at] ||= 0
    options[:max_results] ||= 50
    options[:method] ||= :get

    response = Jiralicious.session.perform_request do
      Jiralicious::Session.send(options[:method],
                                "#{Jiralicious.rest_path}/search",
                                :body =>
                                {:jql => jql,
                                  :startAt => options[:start_at],
                                  :maxResults => options[:max_results]}
                                )
    end

    if response.code == 200
      response = JSON.parse(response.body)
    else
      raise Jiralicious::JqlError
    end
  end
end
