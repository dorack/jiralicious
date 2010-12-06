# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'faraday'

describe Jiralicious::Connection do
  before :each do
    @fake_session = %Q{
      {"session": {
        "name":"JSESSIONID",
        "value":"3BCEFC7E6EC901DADA2A90CA043BEFB6"},
        "loginInfo":{
          "loginCount":9,
          "previousLoginTime":"2010-07-09T11:25:46.337+1000"}
       }
    }

    @faraday_stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.post('/rest/auth/latest/session') { [200, {}, @fake_session] }
    end

    test_adapter = Faraday::Connection.new do |builder|
      builder.adapter :test, @faraday_stubs
    end

    Faraday::Connection.stub!(:new).and_return(test_adapter)
    @connection = Jiralicious::Connection.new(
      :username => "jstewart",
      :password => "topsecret",
      :uri => "http://localhost",
      :api_version => "latest"
    )
  end

  describe "initializing" do
    it "generates a valid session path" do
      @connection.session_path.should == "/rest/auth/latest/session"
    end

    it "generates a valid api path" do
      @connection.api_path.should == "/rest/api/latest/"
    end
  end

  describe "logging in" do
    it "knows if it's logged in" do
      @connection.logged_in?.should be_false
    end

    it "can log in successfully" do
      @connection.login
      @connection.logged_in?.should be_true
      @connection.session.name.should == "JSESSIONID"
    end

    # TODO: Figure out why the hell new stubs aren't working
    xit "raises an exception when it can't log in" do
      @faraday_stubs.post('/rest/auth/latest/session') { [401, {}, "Unauthorized"] }
      lambda { @connection.login }.should raise_exception(Jiralicious::InvalidLogin)
    end
  end
end
