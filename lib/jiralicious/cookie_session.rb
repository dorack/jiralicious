# encoding: utf-8
module Jiralicious
  ##
  # The CookieSesssion class extends the Session class with the
  # functionality of utilizing cookies for authorization management.
  #
  # Deprecated:: CookieSession is deprecated as of version 0.2.0
  #
  class CookieSession < Session
    # Adds attributes to the CookieSession
    attr_accessor :authenticating, :session, :login_info

    # Checks to see if session is active
    def alive?
      @session && @login_info
    end

    # Provides login information on every request
    def before_request
      login if require_login? && !@authenticating
    end

    # Handles the response from the request
    def after_request(response)
      unless @authenticating
        if captcha_required(response)
          raise Jiralicious::CaptchaRequired
            .new("Captacha is required. Try logging into Jira via the web interface")
        elsif cookie_invalid(response)
          # Can usually be fixed by logging in again
          clear_session
          raise Jiralicious::CookieExpired
        end
      end
      @authenticating = false
    end

    # Authenticates the login
    def login
      @authenticating = true
      handler = proc do |response|
        if response.code == 200
          @session = response["session"]
          @login_info = response["loginInfo"]
          self.class.cookies(session["name"] => session["value"])
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

      request(
        :post, "/rest/auth/latest/session",
        body: {
          username: Jiralicious.username,
          password: Jiralicious.password
        }.to_json,
        handler: handler
      )
    end

    # Logs out of the API
    def logout
      handler = proc do
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

      request(:delete, "/rest/auth/latest/session", handler: handler)
    end

    private

    # Handles Captcha if necessary
    def captcha_required(response)
      response.code == 401 &&
        # Fakeweb lowercases headers automatically. :(
        (response.headers["X-Seraph-LoginReason"] == "AUTHENTICATION_DENIED" ||
            response.headers["x-seraph-loginreason"] == "AUTHENTICATION_DENIED")
    end

    # Throws if cookie is invalid
    def cookie_invalid(response)
      response.code == 401 && response.body =~ /cookie/i
    end

    # Checks to see if login is required
    def require_login?
      !(Jiralicious.username.empty? && Jiralicious.password.empty?) && !alive?
    end

    # Resets the current Session
    def clear_session
      @session = @login_info = nil
    end
  end
end
