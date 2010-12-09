# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Jiralicious::Client do
  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.api_version = "latest"
    end
  end

  it "should merge the passed in options from the module options and into the client" do
    client = Jiralicious::Client.new(:username => "kstewart",
                                     :password => "notsecret",
                                     :uri => "http://www.example.com")
    client.username.should == "kstewart"
    client.password.should == "notsecret"
    client.uri.should == "http://www.example.com"
  end

  it "delegates 'make_request' to the connection" do
    client = Jiralicious::Client.new
    client.respond_to?(:make_request).should be_true
  end
end
