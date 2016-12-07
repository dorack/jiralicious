require "oauth"
require "nokogiri"

module Jiralicious
  ##
  # The OauthSesion class extends the default OAuth::AccessToken
  # The functions herein convert between the current Jiralicious
  # and HTTParty formats and those required by OAuth. This is a
  # Bidirectional conversion.
  #
  class OauthSession < OAuth::AccessToken
    attr_accessor :option

    ##
    # After Request reprocesses the response provided in to the
    # HTTParty::Response format that is expected by the rest of
    # the gem.
    #
    def after_request(response)
      @response = HTTParty::Response.new(self, response, lambda { HTTParty::Parser.new(response.body, Jiralicious::Session.format).parse }, :body => response.body)
    end

    ##
    # Initializer extends the functionality of the basic OAuth::AccessToken
    # However provides the base functionality to handle the initial root
    # generation for the custom Jiralicious authentication to JIRA
    #
    def initialize(token = nil, secret = nil)
      self.option = {
        :signature_method => "RSA-SHA1",
        :request_token_path => "/plugins/servlet/oauth/request-token",
        :authorize_path => "/plugins/servlet/oauth/authorize",
        :access_token_path => "/plugins/servlet/oauth/access-token",
        :site => "http://rome:8080"
      }
      if (token.nil? || secret.nil?)
        consumer = OAuth::Consumer.new(Jiralicious.oauth_consumer_key, OpenSSL::PKey::RSA.new(get_secret, Jiralicious.oauth_pass_phrase.to_s), self.option)
        request_token = consumer.get_request_token
        ## request access confirmation ##
        bs = Jiralicious::BasicSession.new
        bsr = bs.request(:get, request_token.authorize_url)
        bsp = HTTParty::Parser.new(bsr.message, :html)
        bsb = Nokogiri::HTML(bsp.body)
        ## Parse confirm page and send form ##
        a = {}
        bsb.xpath("//input").each do |input|
          if (input.get_attribute("name") != "deny" && !input.get_attribute("name").nil?)
            a.merge!({ input.get_attribute("name").to_sym => input.get_attribute("value") })
          end
        end
        urip = "#{request_token.authorize_url.split('?')[0]}?#{build_body(a)}"
        bsr = bs.request(bsb.xpath("//form")[0].get_attribute("method").downcase.to_sym, urip)
        ## Parse response for access ##
        bss = bsr.message.split("&#39;") # brute force method don't know a better way to do this
        crt = request_token.consumer.token_request(request_token.consumer.http_method, (request_token.consumer.access_token_url? ? request_token.consumer.access_token_url : request_token.consumer.access_token_path), request_token, { :oauth_verifier => bss[3] })
        super(request_token.consumer, crt[:oauth_token], crt[:oauth_token_secret])
        self.params = crt
      else
        super(token, secret)
      end
    end

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
      path = options.first
      options = options.last
      before_request if respond_to?(:before_request)
      super(method, path, *options)
      after_request(response) if respond_to?(:after_request)

      response_handler.call(response)
    end

    protected

    ##
    # Restructures the Hash into a param string
    #
    def build_body(a)
      o = ""
      a.each do |k, v|
        o += "#{k}=#{v}&"
      end
      o
    end

    ##
    # returns the oauth_secret parameter or the file
    #
    def get_secret
      if Jiralicious.oauth_secret.nil?
        IO.read(Jiralicious.config_path + Jiralicious.oauth_secret_filename)
      else
        Jiralicious.oauth_secret
      end
    end

    ##
    # Configures the default handler. This can be overridden in
    # the child class to provide additional error handling.
    #
    def handler
      Proc.new do |response|
        case response.code
        when 200..204
          response
        else
          message = response.body
          message = message["errorMessages"].join('\n') if message.is_a?(Hash)
          Jiralicious::JiraError.new(message)
        end
      end
    end
  end
end
