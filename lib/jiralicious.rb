# encoding: utf-8
require 'hashie'
require 'crack'
require 'httparty'
require 'json'

require 'jiralicious/parsers/field_parser'
require 'jiralicious/errors'
require 'jiralicious/base'
require 'jiralicious/field'
require 'jiralicious/custom_field_option'
require 'jiralicious/issue'
require 'jiralicious/issue/fields'
require 'jiralicious/issue/comment'
require 'jiralicious/issue/watchers'
require 'jiralicious/issue/transitions'
require 'jiralicious/component'
require 'jiralicious/versions'
require 'jiralicious/project'
require 'jiralicious/project/avatar'
require 'jiralicious/search'
require 'jiralicious/search_result'
require 'jiralicious/session'
require 'jiralicious/user'
require 'jiralicious/user/avatar'
require 'jiralicious/basic_session'
require 'jiralicious/cookie_session'
require 'jiralicious/oauth_session'
require 'jiralicious/configuration'
require 'jiralicious/avatar'

##
# The Jiralicious module standard options and methods
#
module Jiralicious
  # Adds Configuration functionality
  extend Configuration
  # Adds self functionality
  extend self

  ##
  # Processes the session information and returns the current session object
  #
  def session
    session_type = "#{self.auth_type.to_s.capitalize}Session"
    @session ||= Jiralicious.const_get(session_type).new
  end

  ##
  # Returns the currently defined Rest API path
  #
  def rest_path
    "#{self.uri}/rest/api/#{self.api_version}"
  end
end
