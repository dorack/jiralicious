# encoding: utf-8
require 'jiralicious/configuration'

module Jiralicious
  class Session
    include HTTParty

    format        :json
    headers       'Content-Type' => 'application/json'

    def request(method, *options)
      if options.last.is_a?(Hash) && options.last[:handler]
        response_handler = options.last.delete(:handler)
      else
        response_handler = handler
      end

      self.class.base_uri Jiralicious.uri
      before_request if respond_to?(:before_request)
      response = self.class.send(method, *options)
      after_request(response) if respond_to?(:after_request)

      response_handler.call(response)
    end

    private

    def handler
      Proc.new do |response|
        case response
        when 200..204
          response.body
        else
          message = response.body
          if message.is_a?(Hash)
            message = message['errorMessages'].join('\n')
          end
          Jiralicious::JiraError.new(message)
        end
      end
    end
  end
end
