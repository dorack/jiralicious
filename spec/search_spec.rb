# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Jiralicious, "search" do

  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.api_version = "latest"
    end
  end

  context "when successful" do
    before :each do
      FakeWeb.register_uri(:post,
                           "#{Jiralicious.rest_path}/search",
                           :status => "200",
                           :body => search_json)

    end

    it "instantiates a search result" do
      results = Jiralicious.search("key = HSP-1")
      results.should be_instance_of(Jiralicious::SearchResult)
    end
  end

  context "When there's a problem with the query" do
    before :each do
      FakeWeb.register_uri(:post,
                           "#{Jiralicious.rest_path}/search",
                           :status => "400")
    end

    it "raises an exception" do
      lambda {
        results = Jiralicious.search("key = HSP-1")
      }.should raise_error(Jiralicious::JqlError)
    end
  end
end
