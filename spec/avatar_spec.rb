# encoding: utf-8
require "spec_helper"

describe Jiralicious, "avatar" do

  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/avatar/user/system",
      :status => "200",
      :body => avatar_list_json)
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/avatar/user/temporary",
      :status => "200",
      :body => avatar_temp_json)
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/avatar/user/temporaryCrop",
      :status => "200")
  end

  it "obtain system avatar list" do
    avatar = Jiralicious::Avatar.system('user')
	avatar.should be_instance_of(Jiralicious::Avatar)
	avatar.system.count.should == 2
    avatar.system[0].id.should == '10100'
	avatar.system[1].isSystemAvatar.should == true
  end

  it "sends new avatar" do
    file = "#{File.dirname(__FILE__)}/fixtures/avatar_test.png"
    avatar = Jiralicious::Avatar.temporary('user', {:filename => file, :size => 4035})
	avatar.needsCropping.should == true
  end

  it "crops the current avatar" do
    response = Jiralicious::Avatar.temporary_crop('user', {:cropperWidth => 120,
			 :cropperOffsetX => 50,
			 :cropperOffsety => 50,
			 :needsCropping => false})
	response.response.class.should == Net::HTTPOK
  end

end
