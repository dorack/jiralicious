# encoding: utf-8

module Jiralicious
  module Configuration
    VALID_OPTIONS = [:username, :password, :uri, :api_version]
    DEFAULT_USERNAME = nil
    DEFAULT_PASSWORD = nil
    DEFAULT_URI = nil
    DEFAULT_API_VERSION = "latest"

    def configure
      yield self
    end

    attr_accessor *VALID_OPTIONS

    # Reset when extended into class
    def self.extended(base)
      base.reset
    end
    
    def options
      VALID_OPTIONS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end

    def reset
      self.username = DEFAULT_USERNAME
      self.password = DEFAULT_PASSWORD
      self.uri = DEFAULT_URI
      self.api_version = DEFAULT_API_VERSION
    end
  end
end
