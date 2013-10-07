module Jiralicious
  ##
  # The SearchResult class organizes the response from the Jira API
  # In a way that is easily parsable into Issues.
  #
  class SearchResult
    # Attributes available for usage regarding the current position in the list
    attr_reader :offset, :num_results

    ##
    # Initialization Method
    #
    # Parses the hash into attributes.
    #
    # [Arguments]
    # :search_data    (required)    hash data to be parsed
    #
    def initialize(search_data)
      @issues      = search_data["issues"]
      @offset      = search_data["startAt"]
      @num_results = search_data["total"]
    end

    ##
    # Loads the different issues through the map. This is not recommended
    # for large objects as it can be troublesome to load multiple Issues
    # to locate the desired one. If the user needs to have all of the
    # information available on each issue this method works perfectly for
    # that process.
    #
    def issues
      @issues.map do |issue|
        Jiralicious::Issue.find(issue["key"])
      end
    end

    ##
    # Returns the Issues attribute without loading the extra information.
    # Ideal for a quick scan of the Hash prior to selecting the correct
    # Issue. This method is also used in the lazy loading methodology.
    #
    def issues_raw
      @issues
    end
  end
end
