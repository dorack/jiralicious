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
      "#{Jiralicious.rest_path}/project/EX/avatar/",
      :status => "204")
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/project/EX/avatar/",
      :status => "200")
    FakeWeb.register_uri(:delete,
      "#{Jiralicious.rest_path}/project/EX/avatar/10100",
      :status => "200")
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/project/EX/avatars/",
      :status => "200",
      :body => avatar_list_json)
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/project/EX/avatar/temporary",
      :status => "200",
      :body => avatar_temp_json)
  end

  it "obtain project avatar list" do
    avatar = Jiralicious::Project::Avatar.avatars('EX')
	avatar.should be_instance_of(Jiralicious::Project::Avatar)
	avatar.system.count.should == 2
    avatar.system[0].id.should == '10100'
	avatar.system[1].isSystemAvatar.should == true
  end

  it "sends new project avatar" do
    file = "#{File.dirname(__FILE__)}/fixtures/avatar_test.png"
    avatar = Jiralicious::Project::Avatar.temporary('EX', {:filename => file, :size => 4035})
	avatar.needsCropping.should == true
  end

  it "crops the current project avatar" do
    response = Jiralicious::Project::Avatar.post('EX', {:cropperWidth => 120,
			 :cropperOffsetX => 50,
			 :cropperOffsety => 50,
			 :needsCropping => false})
	response.response.class.should == Net::HTTPOK
  end

  it "updates current project avatar" do
    response = Jiralicious::Project::Avatar.put('EX')
	response.response.class.should == Net::HTTPNoContent
  end

  it "updates current project avatar" do
    response = Jiralicious::Project::Avatar.remove('EX', 10100)
	response.response.class.should == Net::HTTPOK
  end

end
