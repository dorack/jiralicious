# encoding: utf-8

module Jiralicious
  class CookieSession < Session
    attr_accessor :authenticating, :session, :login_info

    def alive?
      @session && @login_info
    end

    def before_request
      self.login if require_login? && !@authenticating
    end

    def after_request(response)
      unless @authenticating
        if captcha_required(response)
          raise Jiralicious::CaptchaRequired.
            new("Captacha is required. Try logging into Jira via the web interface")
        elsif cookie_invalid(response)
          # Can usually be fixed by logging in again
          clear_session
          raise Jiralicious::CookieExpired
        end
      end
      @authenticating = false
    end

    def login
      @authenticating = true
      handler = Proc.new do |response|
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
            raise Jiralicious::JiraError.new(response)
          end
        end
      end

      self.request(:post, '/rest/auth/latest/session',
                   :body => { :username => Jiralicious.username,
                              :password => Jiralicious.password}.to_json,
                   :handler => handler)

    end

    def logout
      handler = Proc.new do |request|
        if response.code == 204
          clear_session
        else
          case response.code
          when 401 then
            raise Jiralicious::NotLoggedIn.new("Not logged in")
          else
            # Give Net::HTTP reason
            raise Jiralicious::JiraError.new(response)
          end
        end
      end

      request(:delete, '/rest/auth/latest/session', :handler => handler)
    end

    private

    def captcha_required(response)
      response.code == 401 &&
        # Fakeweb lowercases headers automatically. :(
        (response.headers["X-Seraph-LoginReason"] == "AUTHENTICATION_DENIED" ||
         response.headers["x-seraph-loginreason"] == "AUTHENTICATION_DENIED")
    end

    def cookie_invalid(response)
      response.code == 401 && response.body =~ /cookie/i
    end

    def require_login?
      !(Jiralicious.username.empty? && Jiralicious.password.empty?) && !alive?
    end

    def clear_session
      @session = @login_info = nil
    end
  end
end
