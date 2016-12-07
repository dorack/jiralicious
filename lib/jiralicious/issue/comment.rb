# encoding: utf-8
module Jiralicious
  class Issue
    ##
    # The Comment class retrieves and controls the functionality
    # of Comments associated with an Issue.
    #
    class Comment < Jiralicious::Base
      # Related Issue Key
      attr_accessor :jira_key

      ##
      # Initialization Method
      #
      # [Arguments]
      # :decoded_json    (optional)    rubyized json object
      #
      def initialize(decoded_json = nil)
        unless (decoded_json.nil?)
          properties_from_hash(decoded_json)
          super(decoded_json)
          parse!(decoded_json)
          if self.respond_to?("comments")
            if self.comments.is_a? Array
              a = {}
              self.comments.each do |comment|
                a["_#{comment['id']}"] = Comment.new(comment)
              end
              self.comments = a
            end
          end
        end
      end

      class << self
        ##
        # Retrieves the Comments based on the Issue Key
        #
        # [Arguments]
        # :key    (required)    issue key
        #
        def find_by_key(key)
          issueKey_test(key)
          response = fetch({ :parent => parent_name, :parent_key => key })
          a = new(response)
          a.jira_key = key
          return a
        end

        ##
        # Retrieves the Comment based on the Issue Key and Comment ID
        #
        # [Arguments]
        # :key    (required)    issue key
        #
        # :id     (required)    comment id
        #
        def find_by_key_and_id(key, id)
          issueKey_test(key)
          response = fetch({ :parent => parent_name, :parent_key => key, :key => id })
          a = new(response)
          a.jira_key = key
          return a
        end

        ##
        # Adds a new Comment to the Issue
        #
        # [Arguments]
        # :comment    (required)    comment to post
        #
        # :key        (required)    issue key
        #
        def add(comment, key)
          issueKey_test(key)
          fetch({ :method => :post, :body => comment, :parent => parent_name, :parent_key => key })
        end

        ##
        # Updates a Comment based on Issue Key and Comment ID
        #
        # [Arguments]
        # :comment    (required)    comment to post
        #
        # :key        (required)    issue key
        #
        # :id         (required)    comment id
        #
        def edit(comment, key, id)
          issueKey_test(key)
          fetch({ :method => :put, :key => id, :body => comment, :parent => parent_name, :parent_key => key })
        end

        ##
        # Removes/Deletes the Comment from the Jira Issue. It is
        # not recommended  to delete comments however the functionality
        # is provided. It is recommended to override this function
        # to throw an error or warning to maintain data integrity
        # in systems that do not allow deleting from a remote location.
        #
        # [Arguments]
        # :key        (required)    issue key
        #
        # :id         (required)    comment id
        #
        def remove(key, id)
          issueKey_test(key)
          fetch({ :method => :delete, :body_to_params => true, :key => id, :parent => parent_name, :parent_key => key })
        end
      end

      ##
      # Retrieves the Comment based on the loaded Issue and Comment ID
      #
      # [Arguments]
      # :id         (required)    comment id
      #
      def find_by_id(id)
        self.class.find_by_key_and_id(@jira_key, id)
      end

      ##
      # Adds a new Comment to the loaded Issue
      #
      # [Arguments]
      # :comment    (required)    comment text
      #
      def add(comment)
        self.class.add(comment, @jira_key)
      end

      ##
      # Updates a Comment based on loaded Issue and Comment
      #
      # [Arguments]
      # :comment    (required)    comment text
      #
      def edit(comment)
        self.class.edit(comment, @jira_key, self.id)
      end

      ##
      # Removes/Deletes the Comment from the Jira Issue. It is
      # not recommended to delete comments. However, the functionality
      # is provided. It is recommended to override this function
      # to throw an error or warning to maintain data integrity
      # in systems that do not allow deleting from a remote location.
      #
      # [Arguments]
      # :id    (optional)    comment id
      #
      def remove(id = self.id)
        self.class.remove(@jira_key, id)
      end
    end
  end
end
