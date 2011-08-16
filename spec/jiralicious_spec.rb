# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Jiralicious do
  it "creates a session on load" do
    Jiralicious.session.should_not be_nil
  end

  it "creates a rest path" do
    Jiralicious.configure do |config|
      config.uri = "http://localhost:8080"
      config.api_version = "2.0"
    end
    Jiralicious.rest_path.should == 'http://localhost:8080/rest/api/2.0'
  end
end
