# encoding: utf-8
require "spec_helper"

describe Jiralicious, "Project Management Class: " do
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
      "#{Jiralicious.rest_path}/project/",
      status: "200",
      body: projects_json
    )
    FakeWeb.register_uri(
      :get,
      "#{Jiralicious.rest_path}/project/EX",
      status: "200",
      body: project_json
    )
    FakeWeb.register_uri(
      :get,
      "#{Jiralicious.rest_path}/project/EX/components",
      status: "200",
      body: project_componets_json
    )
    FakeWeb.register_uri(
      :get,
      "#{Jiralicious.rest_path}/project/EX/versions",
      status: "200",
      body: project_versions_json
    )
    FakeWeb.register_uri(
      :get,
      "#{Jiralicious.rest_path}/project/ABC",
      status: "200",
      body: project_json
    )
    FakeWeb.register_uri(
      :post,
      "#{Jiralicious.rest_path}/search",
      status: "200",
      body: project_issue_list_json
    )
  end

  it "finds all projects" do
    projects = Jiralicious::Project.all
    expect(projects).to be_instance_of(Jiralicious::Project)
    expect(projects.count).to eq(2)
    expect(projects.EX.id).to eq("10000")
  end

  it "finds project issue list class level" do
    issues = Jiralicious::Project.issue_list("EX")
    expect(issues).to be_instance_of(Jiralicious::Issue)
    expect(issues.count).to eq(2)
    expect(issues.EX_1["id"]).to eq("10000")
  end

  it "finds project issue list instance level" do
    project = Jiralicious::Project.find("EX")
    issues = project.issues
    expect(issues).to be_instance_of(Jiralicious::Issue)
    expect(issues.count).to eq(2)
    expect(issues.EX_1["id"]).to eq("10000")
  end

  it "finds project componets" do
    components = Jiralicious::Project.components("EX")
    expect(components.count).to eq(2)
    expect(components.id_10000.name).to eq("Component 1")
    expect(components.id_10050.name).to eq("PXA")
  end

  it "finds project versions" do
    versions = Jiralicious::Project.versions("EX")
    expect(versions.count).to eq(2)
    expect(versions.id_10000.name).to eq("New Version 1")
    expect(versions.id_10000.overdue).to eq(true)
    expect(versions.id_10010.name).to eq("Next Version")
    expect(versions.id_10010.overdue).to eq(false)
  end
end
