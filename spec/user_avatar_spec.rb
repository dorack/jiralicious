# encoding: utf-8
require "spec_helper"

describe Jiralicious, "Project Avatar" do

  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:put,
      "#{Jiralicious.rest_path}/user/avatar/",
      :status => "204")
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/user/avatar/",
      :status => "200")
    FakeWeb.register_uri(:delete,
      "#{Jiralicious.rest_path}/user/avatar/10100?username=fred",
      :status => "200")
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/user/avatars?username=fred",
      :status => "200",
      :body => avatar_list_json)
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/user/avatar/temporary",
      :status => "200",
      :body => avatar_temp_json)
  end

  it "obtain user avatar list" do
    avatar = Jiralicious::User::Avatar.avatars('fred')
	avatar.should be_instance_of(Jiralicious::User::Avatar)
	avatar.system.count.should == 2
    avatar.system[0].id.should == '10100'
	avatar.system[1].isSystemAvatar.should == true
  end

  it "sends new user avatar" do
    file = "#{File.dirname(__FILE__)}/fixtures/avatar_test.png"
    avatar = Jiralicious::User::Avatar.temporary('fred', {:filename => file, :size => 4035})
	avatar.needsCropping.should == true
  end

  it "crops the current user avatar" do
    response = Jiralicious::User::Avatar.post('fred', {:cropperWidth => 120,
			 :cropperOffsetX => 50,
			 :cropperOffsety => 50,
			 :needsCropping => false})
	response.response.class.should == Net::HTTPOK
  end

  it "updates current user avatar" do
    response = Jiralicious::User::Avatar.put('fred')
	response.response.class.should == Net::HTTPNoContent
  end

  it "updates current user avatar" do
    response = Jiralicious::User::Avatar.remove('fred', 10100)
	response.response.class.should == Net::HTTPOK
  end

end
