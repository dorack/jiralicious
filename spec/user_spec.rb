# encoding: utf-8
require "spec_helper"

describe Jiralicious::User, "finding" do
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
      "#{Jiralicious.rest_path}/user?username=test_user",
      status: "200",
      body: user_json
    )
    FakeWeb.register_uri(
      :get,
      "#{Jiralicious.rest_path}/user/search?username=test_user",
      status: "200",
      body: user_array_json
    )
    FakeWeb.register_uri(
      :get,
      "#{Jiralicious.rest_path}/user/assignable/multiProjectSearch?projectKeys=EX",
      status: "200",
      body: user_array_json
    )
    FakeWeb.register_uri(
      :get,
      "#{Jiralicious.rest_path}/user/assignable/search?project=EX",
      status: "200",
      body: user_array_json
    )
    FakeWeb.register_uri(
      :get,
      "#{Jiralicious.rest_path}/user/picker?query=user",
      status: "200",
      body: user_picker_json
    )
  end

  it "by username" do
    expect(Jiralicious::User.find("test_user")).to be_instance_of(Jiralicious::User)
  end

  it "uses the user picker to find a list of current users based on the criteria" do
    user = Jiralicious::User.picker("user")
    expect(user).to be_instance_of(Jiralicious::User)
    expect(user.total).to eq(user.users.length)
    user.users.each do |u|
      expect(u.html).to match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
    end
  end

  it "uses the user search to find a list of matching users" do
    user = Jiralicious::User.search("test_user")
    expect(user).to be_instance_of(Jiralicious::User)
    expect(user.length).to eq(2)
  end

  it "all assignable users for specified project key using multiproject" do
    user = Jiralicious::User.assignable_multiProjectSearch("EX")
    expect(user).to be_instance_of(Jiralicious::User)
    expect(user.length).to eq(2)
    user.each do |_k, u|
      expect(u.emailAddress).to match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
      expect(u.active).to eq(false)
    end
  end

  it "all assignable users for specified project key" do
    user = Jiralicious::User.assignable_search(project: "EX")
    expect(user).to be_instance_of(Jiralicious::User)
    expect(user.length).to eq(2)
    user.each do |_k, u|
      expect(u.emailAddress).to match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
      expect(u.active).to eq(false)
    end
  end
end
