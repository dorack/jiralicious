# encoding: utf-8
module Jiralicious
  class Issue
    ##
    # The Watchers class is used to manage the
    # watchers on an issue.
    #
    class Watchers < Jiralicious::Base
      ##
      # Holds the Issue Key
      #
      attr_accessor :jira_key

      ##
      # Initialization Method
      #
      def initialize(decoded_json = nil)
        unless (decoded_json.nil?)
          properties_from_hash(decoded_json)
          super(decoded_json)
          parse!(decoded_json)
        end
      end

      class << self
        ##
        # Finds all watchers based on the provided Issue Key
        #
        # [Arguments]
        # :key    (required)    issue key to find
        #
        def find_by_key(key)
          issueKey_test(key)
          response = fetch({ :parent => parent_name, :parent_key => key })
          a = new(response)
          a.jira_key = key
          return a
        end

        ##
        # Adds a new Watcher to the Issue
        #
        # [Arguments]
        # :name    (required)    name of the watcher
        #
        # :key     (required)    issue key
        #
        def add(name, key)
          issueKey_test(key)
          fetch({ :method => :post, :body => name, :body_override => true, :parent => parent_name, :parent_key => key })
        end

        ##
        # Removes/Deletes a Watcher from the Issue
        #
        # [Arguments]
        # :name    (required)    name of the watcher
        #
        # :key     (required)    issue key
        #
        def remove(name, key)
          issueKey_test(key)
          fetch({ :method => :delete, :body_to_params => true, :body => { :username => name }, :parent => parent_name, :parent_key => key })
        end
      end

      ##
      # Finds all watchers based on the provided Issue Key
      #
      def find
        self.class.find_by_key(@jira_key)
      end

      ##
      # Adds a new Watcher to the Issue
      #
      # [Arguments]
      # :name    (required)    name of the watcher
      #
      def add(name)
        self.class.add(name, @jira_key)
      end

      ##
      # Removes/Deletes a Watcher from the Issue
      #
      def remove(name)
        self.class.remove(name, @jira_key)
      end
    end
  end
end
