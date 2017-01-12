# encoding: utf-8
require "spec_helper"

describe Jiralicious::Base, "issue keys" do
  it "can contains all capital letters" do
    expect(Jiralicious::Base.issueKey_test("ABC-1", true)).to eq true
  end

  it "can contain a capital letter followed by numbers and underscores" do
    expect(Jiralicious::Base.issueKey_test("ABC_01-1", true)).to eq true
  end

  it "raises an exception on invalid keys by default" do
    expect { Jiralicious::Base.issueKey_test("1-invalid") }.
      to raise_error("The key 1-invalid is invalid")
  end

  it "must start with a letter" do
    expect(Jiralicious::Base.issueKey_test("2013PROJECT-1", true)).to eq false
  end

  it "must not contain characters other than A-Z, 0-9, and _" do
    expect(Jiralicious::Base.issueKey_test("ABC@-1", true)).to eq false
  end

  it "must have an issue number following the project key" do
    expect(Jiralicious::Base.issueKey_test("ABC", true)).to eq false
  end

  it "must have an issue number that is only digits" do
    expect(Jiralicious::Base.issueKey_test("ABC-A", true)).to eq false
  end
end
