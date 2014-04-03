# encoding: utf-8
require "uri"
require 'hash'

module Jiralicious
  ##
  # The Base class encapsulates all of the default functionality necessary in order
  # to properly manage the Hashie::Trash object within the Jiralicious framework.
  #
  class Base < Hashie::Trash

    ##
    # Includes functionality from FieldParser
    #
    include Jiralicious::Parsers::FieldParser

    ##
    # Used to identify if the class has been loaded
    #
    attr_accessor :loaded

    ##
    # Trash Extention properties_from_hash
    # Adds an underscore (_) before a numeric field.
    # This ensures that numeric fields will be treated as strings.
    #
    # [Arguments]
    # :hash    (required)    hash to be added to properties
    #
    def properties_from_hash(hash)
      hash.inject({}) do |newhash, (k, v)|
        k = k.gsub("-", "_")
        k = "_#{k.to_s}" if k =~ /^\d/
        self.class.property :"#{k}"
        newhash[k] = v
        newhash
      end
    end

    class << self
      ##
      # Finds the specified key in relation to the current class.
      # This is based on the inheritance and will create an error
      # if called from the Base Class directly.
      #
      # [Arguments]
      # :key    (required)    object key to find
      #
      # :reload (required)    is object reloading forced
      #
      def find(key, options = {})
        response = fetch({:key => key})
        if options[:reload] == true
          response
        else
          new(response.parsed_response)
        end
      end

      ##
      # Searches for all objects of the inheritance class. This
      # method can create very large datasets and is not recommended
      # for any request that could slow down either Jira or the
      # Ruby application.
      #
      def find_all
        response = fetch()
        new(response)
      end

      ##
      # Generates the endpoint_name based on the current inheritance class.
      #
      def endpoint_name
        self.name.split('::').last.downcase
      end

      ##
      # Generates the parent_name based on the current inheritance class.
      #
      def parent_name
        arr = self.name.split('::')
        arr[arr.length-2].downcase
      end

      ##
      # uses the options to build the URI options necessary to handle the
      # request. Some options are defaulted if not explicit while others
      # are only necessary under specific conditions.
      #
      #
      # [Arguments]
      # :key               (optional)    key of object to fetch
      #
      # :method            (optional)    limited to the standard request types default of :get
      #
      # :parent            (optional)    boolean will the parent object be used
      #
      # :parent_key        (optional)    parent's key (must set :parent to use)
      #
      # :body              (optional)    fields to be sent with the fetch
      #
      # :body_override     (optional)    corrects issues in :body if set
      #
      # :body_to_params    (optional)    forces body to be appended to URI
      #
      # :url               (optional)    overrides auto generated URI with custom URI
      #
      def fetch(options = {})
        options[:method] = :get unless [:get, :post, :put, :delete].include?(options[:method])
        options[:parent_uri] = "#{parent_name}/#{options[:parent_key]}/" unless options[:parent].nil?
        if !options[:body_override]
          options[:body_uri] = (options[:body].is_a? Hash) ? options[:body] : {:body => options[:body]}
        else
          options[:body_uri] = options[:body]
        end
        if options[:body_to_params]
          options[:params_uri] = "?#{options[:body].to_params}" unless options[:body].nil? || options[:body].empty?
          options[:body_uri] = nil
        end
        options[:url_uri] = options[:url].nil? ? "#{Jiralicious.rest_path}/#{options[:parent_uri]}#{endpoint_name}/#{options[:key]}#{options[:params_uri]}" : "#{options[:url]}#{options[:params_uri]}"
        Jiralicious.session.request(options[:method], options[:url_uri], :handler => handler, :body => options[:body_uri].to_json)
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
          when 400
            raise Jiralicious::TransitionError.new(response.inspect)
          when 404
            raise Jiralicious::IssueNotFound.new(response.inspect)
          else
            raise Jiralicious::JiraError.new(response.inspect)
          end
        end
      end

      alias :all :find_all
    end

    ##
    # Generates the endpoint_name based on the current inheritance class.
    #
    def endpoint_name
      self.class.endpoint_name
    end

    ##
    # Generates the parent_name based on the current inheritance class.
    #
    def parent_name
      self.class.parent_name
    end

    ##
    # Searches for all objects of the inheritance class. This method can
    # create very large datasets and is not recommended for any request
    # that could slow down either Jira or the Ruby application.
    #
    def all
      self.class.all
    end

    ##
    # Returns the the logical form of the loaded member. This used
    # to determine if the object is loaded and ready for usage.
    #
    def loaded?
      !!self.loaded
    end

    ##
    # Default reload method is blank. For classes that implement lazy loading
    # this method will be overridden with the necessary functionality.
    #
    def reload
    end

    ##
    # Overrides the default method_missing check. This override is used in lazy
    # loading to ensure that the requested field or method is truly unavailable.
    #
    # [Arguments]
    # :meth     (system)
    #
    # :args     (system)
    #
    # :block    (system)
    #
    def method_missing(meth, *args, &block)
      if !loaded?
        self.loaded = true
        reload
        self.send(meth, *args, &block)
      else
        super
      end
    end

    ##
    # Validates if the provided object is a numeric value
    #
    # [Arguments]
    # :object    (required)    object to be tested
    #
    def numeric?(object)
      true if Float(object) rescue false
    end
  end
end
