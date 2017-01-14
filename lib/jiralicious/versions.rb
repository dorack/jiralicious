# encoding: utf-8
module Jiralicious
  class Version < Jiralicious::Field
    ##
    # Holds the version Key
    #
    property :version_key, from: :id

    class << self
      ##
      # Creates a new version
      #
      # [Arguments]
      # :details     (required)    Version details to be created
      #
      def create(details)
        response = fetch(method: :post, body: details)
        new(response.parsed_response)
      end

      ##
      # Moves the version to a new position
      #
      # [Arguments]
      # :key          (required)    Version key
      #
      # :options      (optional)     Hash of options
      #
      # position
      #      An absolute position, which may have a value of 'First', 'Last', 'Earlier' or 'Later'
      # after
      #      A version to place this version after. The value should be the self link of another version
      #
      def move(key, options = {})
        if options.include?(:position)
          options[:position] = options[:position].downcase.capitalize
        end
        fetch(method: :post, key: "#{key}/move", body: options)
      end

      ##
      # Removes/Deletes a Version from the Issue
      #
      # [Arguments]
      # :key          (required)    Version key
      #
      # :options      (optional)     Hash of options
      #
      def remove(key, options = {})
        fetch(method: :delete, key: key, body_to_params: true, body: options).parsed_response
      end

      ##
      # Returns the number of Issues associated with the Version
      #
      # [Arguments]
      # :id    (required)    Version to count
      #
      def related_issue_counts(id)
        response = fetch(key: "#{id}/relatedIssueCounts")
        response.parsed_response["key"] = id
        Field.new(response.parsed_response)
      end

      ##
      # Updates a version
      #
      # [Arguments]
      # :id          (required)    Version to be updated
      #
      # :details     (required)    Details of the version to be updated
      #
      def update(id, details)
        response = fetch(method: :put, key: id, body: details)
        new(response.parsed_response)
      end

      ##
      # Returns the number of Unresolved Issues associated with the Version
      #
      # [Arguments]
      # :id    (required)    Version to count
      #
      def unresolved_issue_count(id)
        response = fetch(key: "#{id}/unresolvedIssueCount")
        response.parsed_response["key"] = id
        Field.new(response.parsed_response)
      end
    end

    ##
    # Finds all versions based on the provided Issue Key
    #
    def find
      self.class.find(version_key)
    end

    ##
    # Moves the version to a new position
    #
    # [Arguments]
    # :options      (optional)     Hash of options
    #
    # position
    #      An absolute position, which may have a value of 'First', 'Last', 'Earlier' or 'Later'
    # after
    #      A version to place this version after. The value should be the self link of another version
    #
    def move(options = {})
      self.class.move(version_key, options)
    end

    ##
    # Removes/Deletes a Version from the Issue
    #
    # [Arguments]
    # :options      (optional)     Hash of options
    #
    def remove(options = {})
      self.class.remove(version_key, options)
    end

    ##
    # Returns the number of Issues associated with the Version
    #
    def related_issue_counts
      self.class.related_issue_counts(version_key)
    end

    ##
    # Updates a version
    #
    # [Arguments]
    # :details     (required)    Details of the version to be updated
    #
    def update(details)
      details.each do |k, v|
        send("#{k}=", v)
      end
      self.class.update(version_key, details)
    end

    ##
    # Returns the number of Unresolved Issues associated with the Version
    #
    def unresolved_issue_count
      self.class.unresolved_issue_count(version_key).issuesUnresolvedCount
    end
  end
end
