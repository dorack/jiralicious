# encoding: utf-8
require "spec_helper"

describe Jiralicious::Configuration do
  before :each do
    Jiralicious.reset
  end

  it "sets the options to their default value" do
    Jiralicious.username.should be_nil
    Jiralicious.password.should be_nil
    Jiralicious.uri.should be_nil
    Jiralicious.api_version.should == "latest"
    Jiralicious.auth_type.should == :basic
  end

  it "allows setting of options in a block" do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "derp"
      config.uri = "http://example.com/foo/bar"
      config.api_version = "2.0aplha"
      config.auth_type = :cookie_session
    end

    Jiralicious.username.should == "jstewart"
    Jiralicious.password.should == "derp"
    Jiralicious.uri.should == "http://example.com/foo/bar"
    Jiralicious.api_version.should == "2.0aplha"
    Jiralicious.auth_type.should == :cookie_session
  end
end
