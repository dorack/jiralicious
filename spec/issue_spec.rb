# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Jiralicious::Issue, "finding" do

  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.api_version = "latest"
    end
  end

  it "finds the issue by key" do
    FakeWeb.register_uri(:get,
                         "#{Jiralicious.rest_path}/issue/EX-1",
                         :status => "200",
                         :body => issue_json)
    Jiralicious::Issue.find("EX-1").should be_instance_of(Jiralicious::Issue)
    issue = Jiralicious::Issue.find("EX-1")
  end

  it "raises an exception when the issue can't be found or can't be viewed" do
    lambda {
      FakeWeb.register_uri(:get,
                           "#{Jiralicious.rest_path}/issue/EX-1",
                           :status => ["404" "Not Found"])
      Jiralicious::Issue.find("EX-1")
    }.should raise_error(Jiralicious::IssueNotFound)
  end
end
