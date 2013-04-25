# encoding: utf-8
require "spec_helper"

describe Jiralicious, "search" do

  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.auth_type = :cookie
      config.api_version = "latest"
    end

    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/",
      :status => "200",
      :body => comment_json)
    FakeWeb.register_uri(:post,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/",
      :status => "201",
      :body => comment_json)
    FakeWeb.register_uri(:get,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/10000",
      :status => "200",
      :body => comment_single_json)
    FakeWeb.register_uri(:put,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/10000",
      :status => "200",
      :body => comment_single_json)
    FakeWeb.register_uri(:delete,
      "#{Jiralicious.rest_path}/issue/EX-1/comment/10000",
      :status => "204")
  end

  it "finds by isusse key" do
    comments = Jiralicious::Issue::Comment.find_by_key("EX-1")
    comments.should be_instance_of(Jiralicious::Issue::Comment)
    comments.comments.count.should == 1
    comments.comments[0]['id'].should == "10000"
  end

  it "finds by isusse key and comment id" do
    comments = Jiralicious::Issue::Comment.find_by_key_and_id("EX-1", "10000")
    comments.should be_instance_of(Jiralicious::Issue::Comment)
    comments.id.should == "10000"
  end

  it "posts a new comment" do
    response = Jiralicious::Issue::Comment.add({:body => "this is a test"}, "EX-1")
    response.class.should == HTTParty::Response
    response.parsed_response['comments'][0]['id'].to_f.should > 0
  end

  it "updates a comment" do
    response = Jiralicious::Issue::Comment.edit("this is a test", "EX-1", "10000")
  end

  it "deletes a comment" do
    comment = Jiralicious::Issue::Comment.find_by_key_and_id("EX-1", "10000")
    response = comment.remove
    response.response.class.should == Net::HTTPNoContent
  end
end
