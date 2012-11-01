# encoding: utf-8
require 'jiralicious/configuration'

module Jiralicious
  class Session
    include HTTParty
    headers       'Content-Type' => 'application/json'

    def request(method, *options)
      self.class.base_uri Jiralicious.uri
      before_request if respond_to?(:before_request)
      response = self.class.send(method, *options)
      after_request(response) if respond_to?(:after_request)

      response
    end
  end
end
