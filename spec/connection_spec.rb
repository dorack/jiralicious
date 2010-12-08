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
      stub.delete('/rest/auth/latest/session') { [200, {}, ""] }
      stub.get('/dummy/unauthorized') { [401, {}, "401 Unauthorized"] }
      stub.get('/dummy/server_error') { [500, {}, "500 Server Error"] }
      stub.get('/dummy/resource') { [200, {}, ""] }
      stub.get('/dummy/resource/json') { [200, {}, '{"key": "value"}'] }
    end

    test_adapter = Faraday::Connection.new(:headers => {:foo => "bar"}) do |builder|
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

    it "raises an exception when it can't log in" do
      @faraday_stubs.post('/rest/auth/latest/session') { [401, {}, "Unauthorized"] }
      # FIXME: Not sure why I have to do this twice. something with faraday stubs?
      @connection.login
      lambda { @connection.login }.should raise_exception(Jiralicious::InvalidLogin)
    end
  end

  describe "logging out" do
    it "can log out" do
      @connection.login
      @connection.logged_in?.should be_true
      @connection.logout
      @connection.logged_in?.should be_false
    end
  end

  describe "making a request" do
    it "should log in first" do
      @connection.should_receive(:login)
      @connection.make_request('/dummy/resource')
    end

    it "doesn't log in if there's a session" do
      @connection.stub!(:logged_in?).and_return(true)
      @connection.should_receive(:login).never
      @connection.make_request('/dummy/resource')
    end

    it "defaults to :get if no method supplied in the options" do
      faraday_connection = @connection.instance_variable_get(:@faraday_connection)
      faraday_connection.should_receive(:get)
      @connection.stub!(:handle_response)
      @connection.make_request('/dummy/resource')
    end

    it "GETs the resorce and returns the handled response" do
      json = @connection.make_request('/dummy/resource/json')
      json.key.should == "value"
    end

    it "raises an exception when unauthorized" do
      lambda { @connection.make_request('/dummy/unauthorized') }.should raise_error(
        Jiralicious::AuthenticationError
      )
    end

    it "raises an exception when there's a server error" do
      lambda { @connection.make_request('/dummy/server_error') }.should raise_error(
        Jiralicious::JiraError
      )
    end
  end
end
