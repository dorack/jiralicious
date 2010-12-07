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

    def login
      @session = nil
      response = @faraday_connection.post do |req|
        req.path = @session_path
        req.body = {:username => @username, :password => @password}
      end
      begin
        handle_response(response) { |r| @session = r.session }
      rescue Jiralicious::AuthenticationError
        raise Jiralicious::InvalidLogin
      end
    end

    def logout
      return unless @session
      response = @faraday_connection.delete do |req|
        req.path = @session_path
        req.headers = req.headers.merge({:"set-cookie" => session_cookie})
      end
      handle_response(response)
      @session = nil
    end

    def logged_in?
      !@session.nil?
    end

    private

    def handle_response(response, &block)
      case response.status
      when 200 then
        body = response.body
        if body =~ /\w+/
          body = Hashie::Mash.new(JSON.parse(response.body))
        end
        yield body if block_given?
      when 401 then
        raise Jiralicious::AuthenticationError
      else
        raise Jiralicious::JiraError
      end
    end

    def session_cookie
      "#{@session.name}=#{@session.value}"
    end
  end
end
