# encoding: utf-8
require "spec_helper"

describe Jiralicious::Configuration do
  before :each do
    Jiralicious.reset
  end

  it "sets the options to their default value" do
    expect(Jiralicious.username).to be_nil
    expect(Jiralicious.password).to be_nil
    expect(Jiralicious.uri).to be_nil
    expect(Jiralicious.api_version).to eq("latest")
    expect(Jiralicious.auth_type).to eq(:basic)
  end

  it "allows setting of options in a block" do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "derp"
      config.uri = "http://example.com/foo/bar"
      config.api_version = "2.0aplha"
      config.auth_type = :cookie_session
    end

    expect(Jiralicious.username).to eq("jstewart")
    expect(Jiralicious.password).to eq("derp")
    expect(Jiralicious.uri).to eq("http://example.com/foo/bar")
    expect(Jiralicious.api_version).to eq("2.0aplha")
    expect(Jiralicious.auth_type).to eq(:cookie_session)
  end

  it "loads the yml in the specified format into the configuation variables" do
    Jiralicious.load_yml(jira_yml)

    expect(Jiralicious.username).to eq("jira_admin")
    expect(Jiralicious.password).to eq("jira_admin")
    expect(Jiralicious.uri).to eq("http://localhost:8080")
    expect(Jiralicious.api_version).to eq("latest")
    expect(Jiralicious.auth_type).to eq(:basic)
  end
end
