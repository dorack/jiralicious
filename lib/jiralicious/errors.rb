# encoding: utf-8

module Jiralicious
  # General Jira error
  class JiraError < StandardError; end
  # AuthenticateError
  class AuthenticationError < StandardError; end
  # NotLoggedIn error
  class NotLoggedIn < AuthenticationError; end
  # InvalidLogin error
  class InvalidLogin < AuthenticationError; end

  # These are in the JIRA API docs. Not sure about specifics, as the docs don't
  # mention them. Added here for completeness and future implementation.
  # http://confluence.atlassian.com/display/JIRA/JIRA+REST+API+%28Alpha%29+Tutorial

  # Cookie has Expired (depricated)
  class CookieExpired < AuthenticationError; end
  # Captcha is Required (not used)
  class CaptchaRequired < AuthenticationError; end
  # IssueNotFound error (any invalid object)
  class IssueNotFound < StandardError; end
  # JQL Error (error in JQL search(
  class JqlError < StandardError; end
  # Transition Error
  class TransitionError < StandardError; end
end
