# encoding: utf-8
require "spec_helper"

describe Jiralicious, "Project Components Class: " do

  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/component/",
      :status => "200",
      :body => component_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/component/10000",
      :status => "200",
      :body => component_json)
    FakeWeb.register_uri(:delete,
      "#{Jiralicious.rest_path}/component/10000",
      :status => "200",
      :body => nil)
    FakeWeb.register_uri(:put,
      "#{Jiralicious.rest_path}/component/10000",
      :status => "200",
      :body => component_updated_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/component/10000/relatedIssueCounts",
      :status => "200",
      :body => component_ric_json)

  end

  it "find a component" do
    component = Jiralicious::Component.find(10000)
    component.component_key.should == "10000"
    component.name.should == "Component 1"
    component.lead.name.should == "fred"
    component.isAssigneeTypeValid.should == false
  end

  it "create a new component" do
    component = Jiralicious::Component.create({:name=>"Component 1", :description=>"This is a JIRA component", :leadUserName=>"fred", :assigneeType=>"PROJECT_LEAD",:isAssigneeTypeValid=>false,:project=>"DEMO"})
    component.component_key.should == "10000"
    component.name.should == "Component 1"
    component.lead.name.should == "fred"
    component.isAssigneeTypeValid.should == false
    component.assigneeType.should == "PROJECT_LEAD"
  end

  it "update a component" do
    component = Jiralicious::Component.update(10000, {:name=>"Component 2", :description=>"This is a JIRA component. Updated Component.", :leadUserName=>"fred", :assigneeType=>"PROJECT_LEAD",:isAssigneeTypeValid=>false,:project=>"DEMO"})
    component.component_key.should == "10000"
    component.name.should == "Component 2"
    component.lead.name.should == "fred"
    component.isAssigneeTypeValid.should == false
    component.description.should == "This is a JIRA component. Updated Component."
  end

  it "delete a component" do
    component = Jiralicious::Component.remove(10000)
    component.should == nil
  end

  it "component related issue count" do
    component = Jiralicious::Component.find(10000)
    count = component.related_issue_counts
    count.should == 23
  end
end
