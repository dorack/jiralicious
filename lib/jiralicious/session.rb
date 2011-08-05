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
      response = perform_request do
        self.class.post('/rest/auth/latest/session',
                                 :body => {
                                   :username => Jiralicious.username,
                                   :password => Jiralicious.password
                        })
      end

      if response.code == 200
        @session = response["session"]
        @login_info = response["loginInfo"]
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
    end

    def perform_request(options = {}, &block)
      # TODO: check for logging in and login required
      # if not logged in and login is required, try to log in (alive?)
      # skip this step if actually logging in (:options => login is true)
      self.class.base_uri Jiralicious.uri
      block.call
    end

    private

    def require_login?
      Jiralicious.username.empty? && Jiralicious.password.empty?
    end

    def clear_session
      @session = @login_info = nil
    end
  end
end
