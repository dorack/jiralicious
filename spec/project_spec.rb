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

    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/project/",
      :status => "200",
      :body => projects_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/project/EX",
      :status => "200",
      :body => project_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/project/ABC",
      :status => "200",
      :body => project_json)
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/search",
      :status => "200",
      :body => project_issue_list_json)
  end

  it "finds all projects" do
    projects = Jiralicious::Project.all
    projects.should be_instance_of(Jiralicious::Project)
    projects.count.should == 2
    projects.EX.id.should == "10000"
  end

  it "finds project issue list class level" do
    issues = Jiralicious::Project.issue_list("EX")
    issues.should be_instance_of(Jiralicious::Issue)
    issues.count.should == 2
    issues.EX_1['id'].should == "10000"
  end

  it "finds project issue list instance level" do
    project = Jiralicious::Project.find("EX")
    issues = project.issues
    issues.should be_instance_of(Jiralicious::Issue)
    issues.count.should == 2
    issues.EX_1['id'].should == "10000"
  end

end
