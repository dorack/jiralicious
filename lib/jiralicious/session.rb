# encoding: utf-8
require 'jiralicious/configuration'

module Jiralicious
  class Session
    include HTTParty
    attr_accessor :session, :login_info

    def initialize
      @session = nil
      @login_info = nil
    end

    def alive?
      @session && @login_info
    end

    def login
    end

    def logout
    end
  end
end
