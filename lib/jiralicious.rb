# encoding: utf-8
require 'hashie'
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
require 'jiralicious/project'
require 'jiralicious/search'
require 'jiralicious/search_result'
require 'jiralicious/session'
require 'jiralicious/basic_session'
require 'jiralicious/cookie_session'
require 'jiralicious/configuration'

module Jiralicious
  extend Configuration
  extend self

  def session
    session_type = "#{self.auth_type.to_s.capitalize}Session"
    @session ||= Jiralicious.const_get(session_type).new
  end

  def rest_path
    "#{self.uri}/rest/api/#{self.api_version}"
  end
end
