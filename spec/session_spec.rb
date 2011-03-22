# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module ConfiguationHelper
  def self.included(base)
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.api_version = "latest"
    end
  end
end

describe Jiralicious::Session, "logging in" do
  include ConfiguationHelper

  describe "successfully" do
    before :each do
    end

    it "is alive"
    it "populates the session and login info"
  end

  describe "unsuccessfully" do
    it "is not alive"
    it "clears the session and login info"
  end
end

describe Jiralicious::Session, "logging out" do
  include ConfiguationHelper

  it "clears the session and login info"
end
