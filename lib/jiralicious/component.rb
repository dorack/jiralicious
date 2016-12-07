# encoding: utf-8
module Jiralicious
  class Component < Jiralicious::Field
    ##
    # Holds the Component Key
    #
    property :component_key, :from => :id

    class << self
      ##
      # Creates a new component
      #
      # [Arguments]
      # :details     (required)    Component details to be created
      #
      def create(details)
        response = fetch({ :method => :post, :body => details })
        new(response.parsed_response)
      end

      ##
      # Returns the number of Issues associated with the Component
      #
      # [Arguments]
      # :id    (required)    Component to count
      #
      def related_issue_counts(id)
        response = fetch({ :key => "#{id}/relatedIssueCounts" })
        response.parsed_response["id"] = id
        Field.new(response.parsed_response)
      end

      ##
      # Removes/Deletes a Component
      #
      # [Arguments]
      # :remove_id    (required)    Component to remove/delete
      #
      # :target_id    (optional)    Component to move issues to
      #
      def remove(remove_id, target_id = nil)
        body = {}
        unless target_id.nil?
          body.merge!("movIssuesTo" => target_id)
        end
        fetch({ :method => :delete, :key => remove_id, :body_to_params => true, :body => body }).parsed_response
      end

      ##
      # Updates a component
      #
      # [Arguments]
      # :id          (required)    Component to be updated
      #
      # :details     (required)    Details of the component to be updated
      #
      def update(id, details)
        response = fetch({ :method => :put, :key => id, :body => details })
        new(response.parsed_response)
      end
    end

    ##
    # Finds all watchers based on the provided Issue Key
    #
    def find
      self.class.find_by_id(self.component_key)
    end

    ##
    # Returns the number of Issues associated with the Component
    #
    # [Arguments]
    # :id    (required)    Component to count
    #
    def related_issue_counts
      self.class.related_issue_counts(self.component_key).issueCount
    end

    ##
    # Removes/Deletes a Component
    #
    # [Arguments]
    # :target_id    (optional)    Component to move issues to
    #
    def remove(target = nil)
      self.class.remove(self.component_key, target)
    end

    ##
    # Updates a component
    #
    # [Arguments]
    # :details     (required)    Details of the component to be updated
    #
    def update(details)
      details.each do |k, v|
        self.send("#{k.to_s}=", v)
      end
      self.class.update(self.component_key, details)
    end
  end
end
