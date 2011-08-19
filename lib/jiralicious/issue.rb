# encoding: utf-8
module Jiralicious
  class Issue < Hashie::Trash
    property :jira_key, :from  => :key
    property :expand
    property :jira_self, :from => :self
    property :fields
    property :transitions

    def self.find(key, options = {})
      response = Jiralicious.session.perform_request do
        Jiralicious::Session.get("#{Jiralicious.rest_path}/issue/#{key}")
      end

      if response.code == 200
        response = JSON.parse(response.body)
      else
        raise Jiralicious::IssueNotFound
      end

      new(response)
    end
  end
end
