# encoding: utf-8
module Jiralicious
  class Issue
    ##
    # The Transitions Class provides all of the
    # functionality to retrieve, and use a transition
    # associated with an Issue.
    #
    class Transitions < Jiralicious::Base
      # Contains the meta data to process a Transaction
      attr_accessor :meta

      ##
      # Initialization Method
      #
      # [Arguments]
      # :decoded_json    (optional)    rubyized json object
      #
      # :default         (optional)    default issue key
      #
      def initialize(decoded_json = nil, default = nil)
        @loaded = false
        @meta = nil
        if decoded_json.is_a? Array
          decoded_json = decoded_json[0] if decoded_json.length == 1
        end
        return if decoded_json.nil?
        if decoded_json.is_a? String
          self.class.property :jira_key
          self.jira_key = decoded_json
        elsif decoded_json.is_a? Hash
          properties_from_hash(decoded_json)
          super(decoded_json)
          parse!(decoded_json)
          @loaded = true
        else
          self.class.property :jira_key
          self.jira_key = default
          decoded_json.each do |list|
            self.class.property :"id_#{list["id"]}"
            merge!("id_#{list['id']}" => self.class.new(list))
          end
        end
      end

      class << self
        ##
        # Retrieves the associated Transitions based on the Issue Key
        #
        # [Arguments]
        # :key    (required)    issue key
        #
        def find(key)
          issueKey_test(key)
          response = fetch(parent: parent_name, parent_key: key)
          response.parsed_response["transitions"].each do |t|
            t["jira_key"] = key
          end
          new(response.parsed_response["transitions"], key)
        end

        ##
        # Retrieves the Transition based on the Issue Key and Transition ID
        #
        # [Arguments]
        # :key    (required)    issue key
        #
        # :id     (required)    transition id
        #
        def find_by_key_and_id(key, id)
          issueKey_test(key)
          response = fetch(parent: parent_name, parent_key: key, body: { "transitionId" => id }, body_to_params: true)
          response.parsed_response["transitions"].each do |t|
            t["jira_key"] = key
          end
          new(response.parsed_response["transitions"])
        end

        ##
        # Processes the Transition based on the provided options
        #
        # [Arguments]
        # :key      (required)    issue key
        #
        # :id       (required)    transaction id
        #
        # :comment  (optional)    comment to be added with transition
        #
        # :fields   (mixed)       the fields that are required or optional
        #                             based on the individual transition
        #
        def go(key, id, options = {})
          issueKey_test(key)
          transition = { "transition" => { "id" => id } }
          if options[:comment].is_a? String
            transition["update"] = { "comment" => [{ "add" => { "body" => options[:comment].to_s } }] }
          elsif options[:comment].is_a? Jiralicious::Issue::Fields
            transition.merge!(options[:comment].format_for_update)
          elsif options[:comment].is_a? Hash
            transition["update"] = options[:comment]
          end
          if options[:fields].is_a? Jiralicious::Issue::Fields
            transition.merge!(options[:fields].format_for_create)
          elsif options[:fields].is_a? Hash
            transition["fields"] = options[:fields]
          end
          fetch(method: :post, parent: parent_name, parent_key: key, body: transition)
        end

        ##
        # Retrieves the meta data for the Transition based on the
        # options, Issue Key and Transition ID provided.
        #
        # [Arguments]
        # :key      (required)    issue key
        #
        # :id       (required)    transaction id
        #
        # :return   (optional)    boolean flag to determine if an object or hash is returned
        #
        def meta(key, id, options = {})
          issueKey_test(key)
          response = fetch(method: :get, parent: parent_name, parent_key: key, body_to_params: true,
                           body: { "transitionId" => id, "expand" => "transitions.fields" })
          response.parsed_response["transitions"].each do |t|
            t["jira_key"] = key
          end
          options[:return].nil? ? new(response.parsed_response["transitions"], key) : response
        end

        alias find_all find
      end

      ##
      # Retrieves the associated Transitions based on the Issue Key
      #
      def all
        self.class.all(jira_key) if jira_key
      end

      ##
      # Processes the Transition based on the provided options
      #
      # [Arguments]
      # :options are passed on to the 'class.go' function
      #
      def go(options = {})
        self.class.go(jira_key, id, options)
      end

      ##
      # Retrieves the meta data for the Transition based on the
      # options, Issue Key and Transition ID provided.
      #
      def meta
        if @meta.nil?
          l = self.class.meta(jira_key, id, return: true)
          @meta = Field.new(l.parsed_response["transitions"].first)
        end
        @meta
      end
    end
  end
end
