# encoding: utf-8

module Jiralicious
  class AuthenticationError < StandardError; end
  class NotLoggedIn < AuthenticationError; end
  class InvalidLogin < AuthenticationError; end
  class CookieExpired < AuthenticationError; end
  class CaptchaRequired < AuthenticationError; end
end
