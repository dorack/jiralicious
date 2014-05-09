# encoding: utf-8
module Jiralicious
  ##
  # The Project class rolls up the basic functionality for
  # managing Projects within Jira through the Rest API.
  #
  class Project < Jiralicious::Base

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
          self.class.property :"#{list['key']}"
          self.merge!({list['key'] => self.class.find(list['key'])})
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
        response = Jiralicious.search("project=#{key}", {:fields => ["id", "key"]})
        i_out = Issue.new
        response.issues_raw.each do |issue|
          i_out.class.property :"#{issue["key"].gsub("-", "_")}"
          t = Issue.new
          t.load(issue, true)
          i_out[issue["key"].gsub("-", "_")] = t
        end
        i_out
      end
    end

    ##
    # Issues loads the issue list into the current Project.
    # It also acts as a reference for lazy loading of issues.
    #
    attr_accessor :issues
    def issues
      if @issues == nil
        @issues = self.class.issue_list(self.key)
      end
      return @issues
    end
  end
end
