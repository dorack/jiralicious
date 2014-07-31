# encoding: utf-8
require "spec_helper"

describe Jiralicious, "Project Versions Class: " do

  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/version/",
      :status => "200",
      :body => version_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/version/10000",
      :status => "200",
      :body => version_json)
    FakeWeb.register_uri(:delete,
      "#{Jiralicious.rest_path}/version/10000",
      :status => "200",
      :body => nil)
    FakeWeb.register_uri(:put,
      "#{Jiralicious.rest_path}/version/10000",
      :status => "200",
      :body => version_updated_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/version/10000/relatedIssueCounts",
      :status => "200",
      :body => version_ric_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/version/10000/unresolvedIssueCount",
      :status => "200",
      :body => version_uic_json)

  end

  it "find a version" do
    version = Jiralicious::Version.find(10000)
    version.version_key.should == "10000"
    version.name.should == "Version 1"
    version.userReleaseDate.should == "5/Jul/2010"
    version.archived.should == false
  end

  it "create a new version" do
    version = Jiralicious::Version.create({:description=>"An excellent version", :name=>"Version 1", :archived=>false, :released=>true,:releaseDate=>"2010-07-05", :project=>"DEMO"})
    version.version_key.should == "10000"
    version.name.should == "Version 1"
    version.userReleaseDate.should == "5/Jul/2010"
    version.archived.should == false
  end

  it "update a version" do
    version = Jiralicious::Version.update(10000, {:name=>"Version 2", :description=>"This is a JIRA version. Updated Version.", :project=>"DEMO"})
    version.version_key.should == "10000"
    version.name.should == "Version 2"
    version.userReleaseDate.should == "5/Jul/2010"
    version.archived.should == false
    version.description.should == "This is a JIRA version. Updated Version."
  end

  it "delete a version" do
    version = Jiralicious::Version.remove(10000)
    version.should == nil
  end

  it "version related issue count" do
    version = Jiralicious::Version.find(10000)
    count = version.related_issue_counts
    count.issuesFixedCount.should == 23
    count.issuesAffectedCount.should == 101
  end

  it "version unresolved issue count" do
    version = Jiralicious::Version.find(10000)
    count = version.unresolved_issue_count
    count.should == 23
  end
end
