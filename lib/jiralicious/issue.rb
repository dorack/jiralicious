# encoding: utf-8
module Jiralicious
  class Issue < Hashie::Trash
    include Jiralicious::Parsers::FieldParser

    property :jira_key, :from  => :key
    property :expand
    property :jira_self, :from => :self
    property :fields
    property :transitions
    property :id

    def initialize(decoded_json, default = nil, &blk)
      super(decoded_json)
      parse!(decoded_json["fields"])
    end

    def self.find(key, options = {})
      response = Jiralicious.session.request(:get, "#{Jiralicious.rest_path}/issue/#{key}")

      if response.code == 200
        response = JSON.parse(response.body)
      elsif response.code == 404
        raise Jiralicious::IssueNotFound.new(response.body)
      else
        raise Jiralicious::JiraError.new(response.body)
      end

      new(response)
    end

    def self.get_transitions(transitions_url)
      response = Jiralicious.session.request(:get, transitions_url)

      if response.code == 200
        response = JSON.parse(response.body)
      elsif response.code == 404
        raise Jiralicious::IssueNotFound.new(response.body)
      else
        raise Jiralicious::JiraError.new(response.body)
      end
    end

    def self.transition(transitions_url, data)
      response = Jiralicious.session.request(:post, transitions_url, :body => data.to_json)

      case response.code
      when 204
        response.body
      when 400
        error = JSON.parse(response.body)
        raise Jiralicious::TransitionError.new(error['errorMessages'].join('\n'))
      when 404
        error = JSON.parse(response.body)
        raise Jiralicious::IssueNotFound.new(error['errorMessages'].join('\n'))
      end
    end
  end
end
