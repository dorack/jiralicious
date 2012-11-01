# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Jiralicious::Issue, "finding" do

  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.auth_type = :cookie
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:get,
                         "#{Jiralicious.rest_path}/issue/EX-1",
                         :status => "200",
                         :body => issue_json)
  end

  it "finds the issue by key" do
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

  it "translates the JSON properly" do
    issue = Jiralicious::Issue.find("EX-1")
    issue.jira_key.should == "EX-1"
    issue.jira_self.should == "http://example.com:8080/jira/rest/api/2.0/issue/EX-1"
  end
end


describe Jiralicious::Issue, "transitions" do

  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.api_version = "latest"
    end

  end

  it "returns list of possible transitions" do
    FakeWeb.register_uri(:get,
                         "#{Jiralicious.rest_path}/issue/EX-1/transitions",
                         :status => "200",
                         :body => transitions_json)

    transitions = Jiralicious::Issue.get_transitions("#{Jiralicious.rest_path}/issue/EX-1/transitions")
    transitions.should be_instance_of(Hash)
  end

  it "performs transition" do
    FakeWeb.register_uri(:post,
                         "#{Jiralicious.rest_path}/issue/EX-1/transitions",
                         :status => "204",
                         :body => nil)

    result = Jiralicious::Issue.transition("#{Jiralicious.rest_path}/issue/EX-1/transitions",
                                  {"transition" => "3", "fields" => []})
    result.should be_empty
  end

  it "raises an exception on transition failure" do
    FakeWeb.register_uri(:post,
                         "#{Jiralicious.rest_path}/issue/EX-1/transitions",
                         :status => "400",
                         :body => %q{{"errorMessages":["Workflow operation is not valid"],"errors":{}}})
    lambda {
      result = Jiralicious::Issue.transition("#{Jiralicious.rest_path}/issue/EX-1/transitions",
                                    {"transition" => "invalid"})
    }.should raise_error(Jiralicious::TransitionError)
  end

  it "raises an IssueNotFound exception if issue is not found" do
    FakeWeb.register_uri(:post,
                         "#{Jiralicious.rest_path}/issue/EX-1/transitions",
                         :status => "404",
                         :body => %q{{"errorMessages":["Issue Does Not Exist"],"errors":{}}})
    lambda {
      result = Jiralicious::Issue.transition("#{Jiralicious.rest_path}/issue/EX-1/transitions",
                                    {"transition" => "invalid"})
    }.should raise_error(Jiralicious::IssueNotFound)
  end
end
