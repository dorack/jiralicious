# encoding: utf-8
module Jiralicious
  class Issue < Hashie::Trash
    include Jiralicious::Parsers::FieldParser

    property :jira_key, :from  => :key
    property :expand
    property :jira_self, :from => :self
    property :fields
    property :transitions

    def initialize(decoded_json, default = nil, &blk)
      super(decoded_json)
      parse!(decoded_json["fields"])
    end

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

    def self.get_transitions(transitions_url)
      response = Jiralicious.session.perform_request do
        Jiralicious::Session.get(transitions_url)
      end
      JSON.parse(response.body)
    end

    def self.transition(transitions_url, data)
      response = Jiralicious.session.perform_request do
        Jiralicious::Session.post(transitions_url, :body => data.to_json)
      end

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
