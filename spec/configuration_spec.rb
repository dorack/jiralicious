# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Jiralicious::Configuration do
  before :each do
    Jiralicious.reset
  end

  it "sets the options to their default value" do
    Jiralicious.username.should be_nil
    Jiralicious.password.should be_nil
    Jiralicious.uri.should be_nil
    Jiralicious.api_version.should == "latest"
  end

  it "allows setting of options in a block" do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "derp"
      config.uri = "http://example.com/foo/bar"
      config.api_version = "2.0aplha"
    end

    Jiralicious.username.should == "jstewart"
    Jiralicious.password.should == "derp"
    Jiralicious.uri = "http://example.com/foo/bar"
    Jiralicious.api_version = "2.0aplha"
  end
end
