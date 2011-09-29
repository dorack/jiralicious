# encoding: utf-8

module Jiralicious
  class JiraError < StandardError; end
  class AuthenticationError < StandardError; end
  class NotLoggedIn < AuthenticationError; end
  class InvalidLogin < AuthenticationError; end

  # These are in the JIRA API docs. Not sure about specifics, as the docs don't
  # mention them. Added here for completeness and future implementation.
  # http://confluence.atlassian.com/display/JIRA/JIRA+REST+API+%28Alpha%29+Tutorial
  class CookieExpired < AuthenticationError; end
  class CaptchaRequired < AuthenticationError; end
  class IssueNotFound < StandardError; end
  class JqlError < StandardError; end
  class TransitionError < StandardError; end
end
