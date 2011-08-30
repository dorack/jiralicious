# encoding: utf-8

require 'hashie'
require 'httparty'
require 'json'

require 'jiralicious/parsers/field_parser'
require 'jiralicious/issue'
require 'jiralicious/search'
require 'jiralicious/session'
require 'jiralicious/errors'


module Jiralicious
  extend Configuration
  extend self

  def session
    @session ||= Session.new
  end

  def rest_path
    "#{self.uri}/rest/api/#{self.api_version}"
  end
end
