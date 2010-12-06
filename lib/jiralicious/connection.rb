# encoding: utf-8
require 'faraday'

module Jiralicious
  class Connection
    attr_accessor :session, :session_path, :api_path

    def initialize(options)
      @username = options[:username]
      @password = options[:password]
      @uri = options[:uri]
      @api_version = options[:api_version]
      @session_path = "/rest/auth/#{@api_version}/session"
      @api_path = "/rest/api/#{@api_version}/"

      @faraday_connection = Faraday::Connection.new(
        :url => @uri,
        :headers => {
          :user_agent => "Jiralicious Ruby JIRA client",
          :accept => "application/json",
          :"content-type" => "application/json"
        }
      )
    end

    def logged_in?
      !@session.nil?
    end

    def login
      response = @faraday_connection.post do |req|
        req.path = @session_path
        req.body = {:username => @username, :password => @password}
      end

      if response.status == 200
        login_json = Hashie::Mash.new(JSON.parse(response.body))
        @session = login_json.session
      else
        @session = nil
      end
      
      raise Jiralicious::InvalidLogin unless @session
    end
  end
end
