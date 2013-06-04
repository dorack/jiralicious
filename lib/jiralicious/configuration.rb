# encoding: utf-8
require 'ostruct'
module Jiralicious
  module Configuration
    # Array of available attributes
    VALID_OPTIONS = [:username, :password, :uri, :api_version, :auth_type]
    # Default user name set prior to login attempt
    DEFAULT_USERNAME = nil
    # Default password set prior to login attempt
    DEFAULT_PASSWORD = nil
    # Authentication is either :basic or :cookie (depricated)
    DEFAULT_AUTH_TYPE = :basic
    # Default URI set prior to login attempt
    DEFAULT_URI = nil
    # Default API Version can be set any valid version or "latest"
    DEFAULT_API_VERSION = "latest"

    # Enables block configuration mode
    def configure
      yield self
    end

    # Provides access to the array of attributes
    attr_accessor *VALID_OPTIONS

    # Reset when extended into class
    def self.extended(base)
      base.reset
    end

    # Pass options to set the values
    def options
      VALID_OPTIONS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end

    # Resets all attributes to default values
    def reset
      self.username = DEFAULT_USERNAME
      self.password = DEFAULT_PASSWORD
      self.uri = DEFAULT_URI
      self.api_version = DEFAULT_API_VERSION
      self.auth_type = DEFAULT_AUTH_TYPE
    end

    ##
    # Loads the provided YML file.
    #
    # Can provide either direct or relational path to the file. It is recommended to send a direct path
    # due to dynamic loading and/or different file locations due to different deployment methods.
    #
    # [Direct Path] /usr/project/somepath_to_file/jira.yml
    #
    # [Relational Path] Rails.root.to_s + "/config/jira.yml"
    #
    #                   "./config/jira.yml"
    #
    def load_yml(yml_file)
      if File.exist?(yml_file)
        yml_cfg = OpenStruct.new(YAML.load_file(yml_file))
        yml_cfg.jira.each do |k, v|
          instance_variable_set("@#{k}", v)
        end
      else
        reset
      end
    end
  end
end
