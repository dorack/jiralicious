# encoding: utf-8
require "spec_helper"

describe Jiralicious, "search" do
  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end
  end

  context "when successful" do
    before :each do
      FakeWeb.register_uri(
        :post,
        "#{Jiralicious.rest_path}/search",
        status: "200",
        body: search_json
      )
    end

    it "instantiates a search result" do
      results = Jiralicious.search("key = HSP-1")
      expect(results).to be_instance_of(Jiralicious::SearchResult)
    end
  end

  context "When there's a problem with the query" do
    before :each do
      FakeWeb.register_uri(
        :post,
        "#{Jiralicious.rest_path}/search",
        body: '{"errorMessages": ["error"]}',
        status: "400"
      )
    end

    it "raises an exception" do
      l = lambda do
        Jiralicious.search("key = HSP-1")
      end
      expect(l).to raise_error(Jiralicious::JqlError)
    end
  end
end
