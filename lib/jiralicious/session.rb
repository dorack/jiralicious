# encoding: utf-8
require "jiralicious/configuration"

module Jiralicious
  ##
  # The Session class handles the interactions with the Jira Rest API
  # Through the HTTParty gem.
  #
  class Session
    include HTTParty

    # Sets the default format to JSON for send and return
    format        :json
    # Sets the default headers to application/json for send and return
    headers       "Content-Type" => "application/json"

    ##
    # Main access method to request data from the Jira API
    #
    # [Arguments]
    # :method    (required)    http method type
    #
    # :options   (required)    request specific options
    #
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

    ##
    # Configures the default handler. This can be overridden in
    # the child class to provide additional error handling.
    #
    def handler
      Proc.new do |response|
        case response
        when 200..204
          response.body
        else
          message = response.body
          message = message["errorMessages"].join('\n') if message.is_a?(Hash)
          Jiralicious::JiraError.new(message)
        end
      end
    end
  end
end
