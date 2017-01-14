# encoding: utf-8
module Jiralicious
  ##
  # The Project class rolls up the basic functionality for
  # managing Projects within Jira through the Rest API.
  #
  class Project < Jiralicious::Base
    # Contains the Fields Class
    attr_accessor :components
    # Contains the Fields Class
    attr_accessor :versions

    ##
    # Initialization Method
    #
    # [Arguments]
    # :decoded_json    (optional)    rubyized json object
    #
    def initialize(decoded_json)
      @loaded = false
      if decoded_json.is_a? Hash
        properties_from_hash(decoded_json)
        super(decoded_json)
        parse!(decoded_json)
        @loaded = true
      else
        decoded_json.each do |list|
          self.class.property :"#{list["key"]}"
          merge!(list["key"] => self.class.find(list["key"]))
        end
      end
    end

    class << self
      ##
      # Returns a list of issues within the project. The issue list is limited
      # to only return the issue ID and KEY values to minimize the amount of
      # data being returned This is used in lazy loading methodology.
      #
      # [Arguments]
      # :key    (required)    project key
      #
      def issue_list(key)
        response = Jiralicious.search("project=#{key}", fields: %w(id key))
        i_out = Issue.new
        response.issues_raw.each do |issue|
          i_out.class.property :"#{issue["key"].tr("-", "_")}"
          t = Issue.new
          t.load(issue, true)
          i_out[issue["key"].tr("-", "_")] = t
        end
        i_out
      end

      ##
      # Retrieves the components associated with the project
      #
      # [Arguments]
      # :key    (required)    project key to generate components
      #
      def components(key)
        response = fetch(key: "#{key}/components")
        Field.new(response.parsed_response)
      end

      ##
      # Retrieves the versions associated with the project
      #
      # [Arguments]
      # :key      (required)    project key to generate versions
      #
      # :expand   (optional)    expansion options.
      #
      def versions(key, expand = {})
        response = fetch(key: "#{key}/versions", body: expand)
        Field.new(response.parsed_response)
      end
    end

    ##
    # Issues loads the issue list into the current Project.
    # It also acts as a reference for lazy loading of issues.
    #
    attr_accessor :issues
    def issues
      @issues = self.class.issue_list(key) if @issues.nil?
      @issues
    end

    ##
    # Retrieves the components associated with the project
    #
    def components
      @components = self.class.components(key) if @components.nil?
      @components
    end

    ##
    # Retrieves the versions associated with the project
    #
    # [Arguments]
    # :expand   (optional)    expansion options.
    #
    def versions(expand = {})
      if @versions.nil? || !expand.empty?
        @versions = self.class.versions(self.key, expand)
      end
      @versions
    end
  end
end
