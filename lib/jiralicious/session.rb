# encoding: utf-8
require 'jiralicious/configuration'

module Jiralicious
  class Session
    include HTTParty
    attr_accessor :session, :login_info

    format :json

    def alive?
      @session && @login_info
    end

    def login
      response = perform_request(:logging_in => true) do
        self.class.post('/rest/auth/latest/session',
                                 :body => {
                                   :username => Jiralicious.username,
                                   :password => Jiralicious.password
                        })
      end

      if response.code == 200
        @session = response["session"]
        @login_info = response["loginInfo"]
        self.class.cookies({self.session["name"] => self.session["value"]})
      else
        clear_session
        case response.code
        when 401 then
          raise Jiralicious::InvalidLogin.new("Invalid login")
        when 403
          raise Jiralicious::CaptchaRequired.new("Captacha is required. Try logging into Jira via the web interface")
        else
          # Give Net::HTTP reason
          raise Jiralicious::JiraError.new(response.response.message)
        end
      end
    end

    def logout
      response = perform_request do
        self.class.delete('/rest/auth/latest/session')
      end

      if response.code == 204
        clear_session
      else
        case response.code
        when 401 then
          raise Jiralicious::NotLoggedIn.new("Not logged in")
        else
          # Give Net::HTTP reason
          raise Jiralicious::JiraError.new(response.response.message)
        end
      end
    end

    def perform_request(options = {}, &block)
      self.class.base_uri Jiralicious.uri
      self.login if require_login? && !options[:logging_in]

      block.call
    end

    private

    def require_login?
      !(Jiralicious.username.empty? && Jiralicious.password.empty?)
    end

    def clear_session
      @session = @login_info = nil
    end
  end
end
