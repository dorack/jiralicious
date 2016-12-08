# encoding: utf-8
require "spec_helper"

class ParserMock
  include Jiralicious::Parsers::FieldParser

  def initialize(parsed)
    parse!(parsed)
  end
end

describe Jiralicious::Parsers::FieldParser do
  context "parse!" do
    before :each do
      @parsed_data = {
        "testfield" => { "name" => "testfield", "value" => "Test Data" },
        "without_hash" => "test",
        "methods" => { "name" => "methods", "value" => "Test Data 2" },
        "testField" => { "name" => "testField", "value" => "Test Data 3" },
        "test_field_dash" => { "name" => "test-field-dash", "value" => "Test Data 4" },
        "test_field_space" => { "name" => "test field space", "value" => "Test Data 5" },
        "test_field_hash" => { "name" => "test_field_hash", "value" => { "it" => "is a Hash" } },
        "test_field_array" => { "name" => "test_field_array", "value" => ["Not a hash"] },
        "test_field_array_with_hash" => { "name" => "test_field_array_with_hash",
                                          "value" => [{ "try" => "this" }] }
      }
      @parsed_class = ParserMock.new(@parsed_data)
    end

    it "raises an error when a hash is not passed in" do
      expect(lambda { ParserMock.new }).to raise_error(ArgumentError)
    end

    it "creates a hash to store data from the fields internally" do
      h = @parsed_class.instance_variable_get("@jiralicious_field_parser_data")
      expect(h).to be_instance_of(Hash)
    end

    context "defining methods" do
      it "defines getter methods on the object it's called in" do
        expect(@parsed_class.testfield).to eq("Test Data")
      end

      it "prefixes a defined method with jira_ when the method already exists" do
        expect(@parsed_class.jira_methods).to eq("Test Data 2")
      end

      it "downcases java idiom method names" do
        expect(@parsed_class.test_field).to eq("Test Data 3")
      end

      it "converts nonword  to underscore" do
        expect(@parsed_class.test_field_dash).to eq("Test Data 4")
        expect(@parsed_class.test_field_space).to eq("Test Data 5")
      end
    end

    context "mashifying data" do
      it "makes hashes a mash" do
        expect(@parsed_class.test_field_hash).to be_instance_of(Hashie::Mash)
      end

      it "recursively makes array elements mashes" do
        m = @parsed_class.test_field_array_with_hash.first
        expect(m).to be_instance_of(Hashie::Mash)
      end

      it "leaves array data alone when it's not a hash" do
        expect(@parsed_class.test_field_array).to eq(["Not a hash"])
      end
    end
  end
end
