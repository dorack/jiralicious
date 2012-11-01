# encoding: utf-8

require 'hashie'
require 'httparty'
require 'json'


require 'jiralicious/parsers/field_parser'
require 'jiralicious/errors'
require 'jiralicious/issue'
require 'jiralicious/search'
require 'jiralicious/search_result'
require 'jiralicious/session'
require 'jiralicious/basic_session'
require 'jiralicious/cookie_session'


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
