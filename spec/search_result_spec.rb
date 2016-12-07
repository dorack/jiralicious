# encoding: utf-8
require "spec_helper"

describe Jiralicious::SearchResult do
  before :each do
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1",
      :status => "200",
      :body => issue_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/",
      :status => "200",
      :body => comment_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/watchers/",
      :status => "200",
      :body => watchers_json)
  end

  let(:search_data) {
    {
      "startAt" => 0,
      "maxResults" =>  50,
      "total" =>  1,
      "issues" => [{
          "self" => "http://www.example.com/jira/rest/api/2.0/jira/rest/api/2.0/issue/EX-1",
          "key" =>  "EX-1"
        }]
    }
  }
  let(:search_result) { Jiralicious::SearchResult.new(search_data) }

  it "assigns an array to back the search results" do
    expect(search_result.instance_variable_get('@issues')).to eq(
      [
        {
          "self" => "http://www.example.com/jira/rest/api/2.0/jira/rest/api/2.0/issue/EX-1",
          "key" => "EX-1"
        }
      ]
    )
  end

  it "knows it's offset" do
    expect(search_result.offset).to eq(0)
  end

  it "knows how many results are returned from the web service" do
    expect(search_result.num_results).to eq(1)
  end

  it "fetches issues" do
    expect(search_result.issues.first).to be_instance_of(Jiralicious::Issue)
  end

  it "checks the issues raw result" do
    expect(search_result.issues_raw.class).to eq(Array)
  end
end
