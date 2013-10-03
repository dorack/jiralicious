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

    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/user?username=test_user",
      :status => "200",
      :body => user_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/user/search?username=test_user",
      :status => "200",
      :body => user_array_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/user/assignable/multiProjectSearch?projectKeys=EX",
      :status => "200",
      :body => user_array_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/user/assignable/search?project=EX",
      :status => "200",
      :body => user_array_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/user/picker?query=user",
      :status => "200",
      :body => user_picker_json)
  end

  it "by username" do
    Jiralicious::User.find("test_user").should be_instance_of(Jiralicious::User)
    user = Jiralicious::User.find("test_user")
  end

  it "uses the user picker to find a list of current users based on the criteria" do
    Jiralicious::User.picker("user").should be_instance_of(Jiralicious::User)
    user = Jiralicious::User.picker("user")
    user.total.should == user.users.length
    user.users.each do |u|
      u.html.should =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
    end
  end

  it "uses the user search to find a list of matching users" do
    Jiralicious::User.search("test_user").should be_instance_of(Jiralicious::User)
    user = Jiralicious::User.search("test_user")
    user.length.should == 2
  end

  it "all assignable users for specified project key using multiproject" do
    Jiralicious::User.assignable_multiProjectSearch("EX").should be_instance_of(Jiralicious::User)
    user = Jiralicious::User.assignable_multiProjectSearch("EX")
    user.length.should == 2
  user.each do |k, u|
      u.emailAddress.should =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
    u.active.should == false
    end
  end

  it "all assignable users for specified project key" do
    Jiralicious::User.assignable_search({:project => "EX"}).should be_instance_of(Jiralicious::User)
    user = Jiralicious::User.assignable_search({:project => "EX"})
    user.length.should == 2
  user.each do |k, u|
      u.emailAddress.should =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
    u.active.should == false
    end
  end
end

###########################################################################################################

