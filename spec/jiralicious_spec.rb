# encoding: utf-8
require "spec_helper"

describe Jiralicious do
  it "creates a session on load" do
    expect(Jiralicious.session).to_not be_nil
  end

  it "creates a rest path" do
    Jiralicious.configure do |config|
      config.uri = "http://localhost:8080"
      config.api_version = "2.0"
    end
    expect(Jiralicious.rest_path).to eq("http://localhost:8080/rest/api/2.0")
  end
end
