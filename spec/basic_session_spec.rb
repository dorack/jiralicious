# encoding: utf-8
require "spec_helper"

describe  "performing a request" do
  before :each do
    Jiralicious.configure do |config|
      config.uri = "http://jstewart:topsecret@localhost"
    end

    FakeWeb.register_uri(:get,
      Jiralicious.uri + '/ok',
      :status => "200")
  end

  let(:session) { Jiralicious::BasicSession.new }

  it "sets the basic auth info beforehand" do
    Jiralicious::BasicSession.should_receive(:basic_auth).with("jstewart", "topsecret")
    session.request(:get, '/ok')
  end
end
