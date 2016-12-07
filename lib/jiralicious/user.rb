# encoding: utf-8
module Jiralicious
  ##
  # The User class rolls up the functionality of user management.
  # This class contains methods to manage Users from Ruby via the
  # API.
  #
  class User < Jiralicious::Base
    ##
    # Initialization Method
    #
    # [Arguments]
    # :decoded_json    (optional)    rubyized json object
    #
    def initialize(decoded_json = nil)
      @loaded = false
      unless decoded_json.nil?
        if decoded_json.is_a? Hash
          decoded_json = properties_from_hash(decoded_json)
          super(decoded_json)
          parse!(decoded_json)
          self.each do |k, v|
            if v.is_a? Hash
              self[k] = self.class.new(v)
            elsif v.is_a? Array
              v.each_index do |i|
                if v[i].is_a? Hash
                  v[i] = self.class.new(v[i])
                end
              end
              self[k] = v
            end
          end
          @loaded = true
        else
          i = 0
          decoded_json.each do |list|
            if !list["id"].nil?
              if numeric? list["id"]
                id = :"id_#{list["id"]}"
              else
                id = :"#{list["id"]}"
              end
            else
              id = :"_#{i}"
              i += 1
            end
            self.class.property id
            self[id] = self.class.new(list)
          end
        end
      end
    end

    class << self
      ##
      # Retrieves the user by UserName.
      #
      # A valid request will return the user details.
      # An invalid request will throw an error.
      #
      # [Arguments]
      # :username   (required)    Must be correct username, no partials
      #
      def find(username)
        response = fetch({ :url => "#{Jiralicious.rest_path}/#{endpoint_name}", :method => :get, :body_to_params => true, :body => { :username => username } })
        return self.new(response.parsed_response)
      end

      ##
      # Returns a list of users matching the criteria
      #
      # [Arguments]
      # :projectKey (required)    Should be upper case
      #
      # :username   (optional)    Must be correct username, no partials
      #
      # :startAt    (optional)    Integer
      #
      # :maxResults (optional)    Integer
      #
      def assignable_multiProjectSearch(projectKeys, options = {})
        options.merge!({ :projectKeys => projectKeys.upcase })
        response = fetch({ :method => :get, :key => "assignable/multiProjectSearch", :body_to_params => true, :body => options })
        return self.new(response.parsed_response)
      end

      ##
      # Returns a list of users matching the criteria
      #
      # [Arguments]
      # :project            (required)    Should be upper case
      #
      #              OR
      #
      # :issueKey           (required)    Should be upper case
      #
      # :username           (optional)    Must be correct username,
      #                                     no partials, cannot be by itself
      #
      # :startAt            (optional)    Integer
      #
      # :maxResults         (optional)    Integer
      #
      # :ActionDescriptorId (optional)    Integer
      #
      def assignable_search(options = {})
        options[:project] = options[:project].upcase unless options[:project].nil?
        options[:issueKey] = options[:issueKey].upcase unless options[:issueKey].nil?
        response = fetch({ :method => :get, :key => "assignable/search", :body_to_params => true, :body => options })
        return self.new(response.parsed_response)
      end

      ##
      # Uses the user picker to find specified users
      #
      # [Arguments]
      # :query         (required)    Name of user or username part or full
      #
      # :maxResults    (optional)    Integer
      #
      # :showAvatar    (optional)    Boolean, default false
      #
      # :exclude       (optional)    Users to exclude
      #
      def picker(query, options = {})
        options.merge!({ :query => query })
        response = fetch({ :method => :get, :key => "picker", :body_to_params => true, :body => options })
        return self.new(response.parsed_response)
      end

      ##
      # Uses the user search to find specified users by username
      #
      # [Arguments]
      # :username           (required)    Name of user or username part or full
      #
      # :startAt            (optional)    Integer
      #
      # :maxResults         (optional)    Integer
      #
      # :includeActive      (optional)    Boolean, default true
      #
      # :includeInactive    (optional)    Boolean, default true
      #
      def search(username, options = {})
        options.merge!({ :username => username })
        response = fetch({ :method => :get, :key => "search", :body_to_params => true, :body => options })
        return self.new(response.parsed_response)
      end
    end
  end
end
