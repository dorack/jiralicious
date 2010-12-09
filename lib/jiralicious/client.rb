# encoding: utf-8
require 'forwardable'
require 'jiralicious/connection'
require 'jiralicious/configuration'

module Jiralicious
  class Client
    extend Forwardable
    def_delegator :@connection, :make_request

    attr_accessor *Configuration::VALID_OPTIONS

    def initialize(options = {})
      # Merge into module configuration
      options = Jiralicious.options.merge(options)
      Configuration::VALID_OPTIONS.each do |key|
        send("#{key}=", options[key])
      end

      @connection = Connection.new(:username => username,
                                   :password => password,
                                   :uri => uri,
                                   :api_version => api_version)
    end
  end
end
