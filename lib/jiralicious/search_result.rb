module Jiralicious
  class SearchResult
    attr_reader :offset, :num_results

    def initialize(search_data)
      @issues      = search_data["issues"]
      @offset      = search_data["startAt"]
      @num_results = search_data["total"]
    end

    def issues
      @issues.map do |issue|
        Jiralicious::Issue.find(issue["key"])
      end
    end

    def issues_raw
      @issues
    end
  end
end
