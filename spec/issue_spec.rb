# encoding: utf-8
require "spec_helper"

describe Jiralicious::Issue, "finding" do
  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1",
      :status => "200",
      :body => issue_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/",
      :status => "200",
      :body => comment_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/watchers/",
      :status => "200",
      :body => watchers_json)
  end

  it "finds the issue by key" do
    expect(Jiralicious::Issue.find("EX-1")).to be_instance_of(Jiralicious::Issue)
  end

  it "raises an exception when the issue can't be found or can't be viewed" do
    l = lambda do
      FakeWeb.register_uri(:get,
        "#{Jiralicious.rest_path}/issue/EX-1",
        :body => '{"errorMessages": ["error"]}',
        :status => ["404 Not Found"])
      Jiralicious::Issue.find("EX-1")
    end
    expect(l).to raise_error(Jiralicious::IssueNotFound)
  end

  it "translates the JSON properly" do
    issue = Jiralicious::Issue.find("EX-1")
    expect(issue.jira_key).to eq("EX-1")
    expect(issue.jira_self).to eq("http://example.com:8080/jira/rest/api/2.0/issue/EX-1")
  end
end

#################################################################################################################

describe Jiralicious::Issue, "Managing Issues" do
  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/issue/",
      :status => "200",
      :body => issue_create_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1",
      :status => "200",
      :body => issue_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/",
      :status => "200",
      :body => comment_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/watchers/",
      :status => "200",
      :body => watchers_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-2",
      :status => "200",
      :body => issue_2_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-2/comment/",
      :status => "200",
      :body => '{"startAt": 0,"maxResults": 0,"total": 0,"comments": []}')
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-2/watchers/",
      :status => "200",
      :body => '{"self": "http://www.example.com/jira/rest/api/2/issue/EX-1/watchers","isWatching": false,"watchCount": 1,"watchers": [{"self": "http://www.example.com/jira/rest/api/2/user?username=fred","name": "fred","avatarUrls": {"16x16": "http://www.example.com/jira/secure/useravatar?size=small&ownerId=fred","48x48": "http://www.example.com/jira/secure/useravatar?size=large&ownerId=fred"},"displayName": "Fred F. User","active": false}]}')
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-3",
      :status => "200",
      :body => issue_3_json)
    FakeWeb.register_uri(:put,
      "#{Jiralicious.rest_path}/issue/EX-3",
      :status => "200",
      :body => issue_update_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-3/comment/",
      :status => "200",
      :body => '{"startAt": 0,"maxResults": 0,"total": 0,"comments": []}')
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-3/watchers/",
      :status => "200",
      :body => '{"self": "http://www.example.com/jira/rest/api/2/issue/EX-1/watchers","isWatching": false,"watchCount": 1,"watchers": [{"self": "http://www.example.com/jira/rest/api/2/user?username=fred","name": "fred","avatarUrls": {"16x16": "http://www.example.com/jira/secure/useravatar?size=small&ownerId=fred","48x48": "http://www.example.com/jira/secure/useravatar?size=large&ownerId=fred"},"displayName": "Fred F. User","active": false}]}')
  end

  it "loads a hash in to the issue without subfields" do
    issue = Jiralicious::Issue.new
    issue.load(JSON.parse(issue_json), false)
    expect(issue.jira_key).to eq("EX-1")
    expect(issue.comments.count).to eq(0)
    expect(issue.watchers.count).to eq(0)
  end

  it "loads a hash in to the issue with subfields" do
    issue = Jiralicious::Issue.new
    issue.load(JSON.parse(issue_json))
    expect(issue.jira_key).to eq("EX-1")
    expect(issue.comments.comments.count).to eq(1)
    expect(issue.watchers.watchers.count).to eq(1)
  end

  it "creates a new issue through fields" do
    issue = Jiralicious::Issue.new
    issue.fields.set_id("project", "10000")
    issue.fields.set("summary", "this is a test of creating a scratch ticket")
    issue.fields.set_id("issuetype", "7")
    issue.fields.set_name("assignee", "stanley.handschuh")
    issue.fields.set_id("priority", "1")
    issue.fields.set("labels", ["new_label_p"])
    issue.fields.set("environment", "example of environment")
    issue.fields.set("description", "example of the description extending")
    issue.save!

    expect(issue.jira_key).to eq("EX-2")
    expect(issue.comments.comments.count).to eq(0)
    expect(issue.watchers.watchers.count).to eq(1)
  end

  it "creates a new issue thgrough load with reload" do
    hash = { "fields" => { "project" => { "id" => "10000" },
        "summary" => "this is a test of creating a scratch ticket",
        "issuetype" => { "id" => "7" },
        "assignee" => { "name" => "stanley.handschuh" },
        "priority" => { "id" => "1" },
        "labels" => ["new_label_p"],
        "environment" => "example of environment",
        "description" => "example of the description extending"
      } }
    issue = Jiralicious::Issue.new
    issue.load(hash, true)
    issue.save!

    expect(issue.jira_key).to eq("EX-2")
    expect(issue.comments.comments.count).to eq(0)
    expect(issue.watchers.watchers.count).to eq(1)
  end

  it "creates a new issue thgrough load without reload" do
    hash = { "fields" => { "project" => { "id" => "10000" },
        "summary" => "this is a test of creating a scratch ticket",
        "issuetype" => { "id" => "7" },
        "assignee" => { "name" => "stanley.handschuh" },
        "priority" => { "id" => "1" },
        "labels" => ["new_label_p"],
        "environment" => "example of environment",
        "description" => "example of the description extending"
      } }
    issue = Jiralicious::Issue.new
    issue.load(hash)
    issue.save!

    expect(issue.jira_key).to eq("EX-2")
    expect(issue.comments.comments.count).to eq(0)
    expect(issue.watchers.watchers.count).to eq(1)
  end

  it "creates a new issue through new" do
    hash = { "project" => { "id" => "10000" },
        "summary" => "this is a test of creating a scratch ticket",
        "issuetype" => { "id" => "7" },
        "assignee" => { "name" => "stanley.handschuh" },
        "priority" => { "id" => "1" },
        "labels" => ["new_label_p"],
        "environment" => "example of environment",
        "description" => "example of the description extending"
      }
    issue = Jiralicious::Issue.new(hash)
    issue.save!

    expect(issue.jira_key).to eq("EX-2")
    expect(issue.comments.comments.count).to eq(0)
    expect(issue.watchers.watchers.count).to eq(1)
  end

  it "updates a new issue" do
    issue = Jiralicious::Issue.find("EX-3")
    issue.fields.append_a("labels", ["test_label"])
    issue.fields.append_s("description", " updated description ")
    issue.save

    expect(issue.jira_key).to eq("EX-3")
    expect(issue["fields"]["labels"]).to eq(["test_label"])
    expect(issue["fields"]["description"]).to eq("example bug report updated description ")
  end
end

#################################################################################################################

describe Jiralicious::Issue, "Managing Issues" do
  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1",
      :status => "200",
      :body => issue_json)
    FakeWeb.register_uri(:delete,
      "#{Jiralicious.rest_path}/issue/EX-1",
      :status => "204")
    FakeWeb.register_uri(:put,
      "#{Jiralicious.rest_path}/issue/EX-1/assignee",
      :status => "204")
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/",
      :status => "200",
      :body => comment_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/watchers/",
      :status => "200",
      :body => watchers_json)
  end

  it "update the assignee instance" do
    issue = Jiralicious::Issue.find("EX-1")
    response = issue.set_assignee("jira_admin")
    expect(response.response.class).to eq(Net::HTTPNoContent)
  end

  it "update the assignee class" do
    response = Jiralicious::Issue.assignee("jira_admin", "EX-1")
    expect(response.response.class).to eq(Net::HTTPNoContent)
  end

  it "deletes the issue at the class level" do
    response = Jiralicious::Issue.remove("EX-1")
    expect(response.response.class).to eq(Net::HTTPNoContent)
  end

  it "deletes the issue at the instance level" do
    issue = Jiralicious::Issue.find("EX-1")
    response = issue.remove
    expect(response.response.class).to eq(Net::HTTPNoContent)
  end
end

#################################################################################################################

describe Jiralicious::Issue, "Issue Information and Field Class" do
  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/createmeta?projectKeys=EX&expand=projects.issuetypes.fields.&issuetypeIds=",
      :status => "200",
      :body => issue_createmeta_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/editmeta",
      :status => "200",
      :body => issue_editmeta_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1",
      :status => "200",
      :body => issue_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/",
      :status => "200",
      :body => comment_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/watchers/",
      :status => "200",
      :body => watchers_json)
  end

  it "retrieve createmeta for project class level" do
    meta = Jiralicious::Issue.createmeta("EX")
    expect(meta.class).to eq(Jiralicious::Field)
    expect(meta.projects[0].key).to eq("EX")
  end

  it "retrieve createmeta for project instance level" do
    issue = Jiralicious::Issue.find("EX-1")
    meta = issue.createmeta
    expect(meta.class).to eq(Jiralicious::Field)
    expect(meta.projects[0].key).to eq("EX")
  end

  it "retrieve editmeta for project class level" do
    meta = Jiralicious::Issue.editmeta("EX-1")
    expect(meta.class).to eq(Jiralicious::Field)
    expect(meta.key).to eq("EX-1")
    expect(meta.fields.summary.required).to eq(false)
  end

  it "retrieve editmeta for project instance level" do
    issue = Jiralicious::Issue.find("EX-1")
    meta = issue.editmeta
    expect(meta.class).to eq(Jiralicious::Field)
    expect(meta.key).to eq("EX-1")
    expect(meta.jira_key).to eq("EX-1")
    expect(meta.fields.summary.required).to eq(false)
  end
end

#################################################################################################################

describe Jiralicious::Issue, "transitions" do
  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
    config.auth_type = :basic
      config.api_version = "latest"
    end
  end

  it "returns list of possible transitions" do
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/transitions",
      :status => "200",
      :body => transitions_json)

    transitions = Jiralicious::Issue.get_transitions("#{Jiralicious.rest_path}/issue/EX-1/transitions")
    expect(transitions).to be_instance_of(Hash)
  end

  it "performs transition" do
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/issue/EX-1/transitions",
      :status => "204",
      :body => nil)

    result = Jiralicious::Issue.transition("#{Jiralicious.rest_path}/issue/EX-1/transitions",
      { "transition" => "3", "fields" => [] })
    expect(result).to be_nil
  end

  it "raises an exception on transition failure" do
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/issue/EX-1/transitions",
      :status => "400",
      :body => '{"errorMessages":["Workflow operation is not valid"],"errors":{}}')
    l = lambda do
      result = Jiralicious::Issue.transition("#{Jiralicious.rest_path}/issue/EX-1/transitions",
        { "transition" => "invalid" })
    end
    expect(l).to raise_error(Jiralicious::TransitionError)
  end

  it "raises an IssueNotFound exception if issue is not found" do
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/issue/EX-1/transitions",
      :status => "404",
      :body => '{"errorMessages":["Issue Does Not Exist"],"errors":{}}')
    l = lambda do
      result = Jiralicious::Issue.transition("#{Jiralicious.rest_path}/issue/EX-1/transitions",
        { "transition" => "invalid" })
    end
    expect(l).to raise_error(Jiralicious::IssueNotFound)
  end
end
