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

    FakeWeb.register_uri(
      :get,
      "#{Jiralicious.rest_path}/issue/EX-1/watchers/",
      status: "200",
      body: watchers_json
    )
    FakeWeb.register_uri(
      :post,
      "#{Jiralicious.rest_path}/issue/EX-1/watchers/",
      status: "204"
    )
    FakeWeb.register_uri(
      :delete,
      "#{Jiralicious.rest_path}/issue/EX-1/watchers/?username=fred",
      status: "204"
    )
  end

  it "finds by issue key" do
    watchers = Jiralicious::Issue::Watchers.find_by_key("EX-1")
    expect(watchers).to be_instance_of(Jiralicious::Issue::Watchers)
    expect(watchers.watchers.count).to eq(1)
    expect(watchers.watchers[0]["name"]).to eq("fred")
  end

  it "adds a new watcher" do
    response = Jiralicious::Issue::Watchers.add("fred", "EX-1")
    expect(response.response.class).to eq(Net::HTTPNoContent)
  end

  it "removes a watcher" do
    response = Jiralicious::Issue::Watchers.remove("fred", "EX-1")
    expect(response.response.class).to eq(Net::HTTPNoContent)
  end
end
