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
      response = Jiralicious.session.request(:get, "#{Jiralicious.rest_path}/issue/#{key}", :handler => handler)
      new(response)
    end

    def self.get_transitions(transitions_url)
      Jiralicious.session.request(:get, transitions_url, :handler => handler)
    end

    def self.transition(transitions_url, data)
      Jiralicious.session.request(:post, transitions_url,
                                  :handler => handler,
                                  :body => data.to_json)
    end

    def self.handler
      Proc.new do |response|
        case response.code
        when 200..204
          response
        when 400
          raise Jiralicious::TransitionError.new(response['errorMessages'].join('\n'))
        when 404
          raise Jiralicious::IssueNotFound.new(response['errorMessages'].join('\n'))
        else
          raise Jiralicious::JiraError.new(response['errorMessages'].join('\n'))
        end
      end
    end
  end
end
