# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

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
        "testfield" => {"name" => "testfield", "value"  => "Test Data"},
        "methods" => {"name" => "methods", "value" => "Test Data 2"},
        "testField" => {"name" => "testField", "value" => "Test Data 3"},
        "test_field_dash" => {"name" => "test-field-dash", "value" => "Test Data 4"},
        "test_field_space" => {"name" => "test field space", "value" => "Test Data 5"},
        "test_field_hash" => {"name" => "test_field_hash", "value" => {"it" => "is a Hash"}},
        "test_field_array" => {"name" => "test_field_array", "value" => ["Not a hash"]},
        "test_field_array_with_hash" => {"name" => "test_field_array_with_hash",
          "value" => [{"try" => "this"}]}
      }
      @parsed_class = ParserMock.new(@parsed_data)
    end

    it "raises an error when a hash is not passed in" do
      lambda { ParserMock.new }.should raise_error(ArgumentError)
    end

    it "creates a hash to store data from the fields internally" do
      @parsed_class.instance_variable_get("@jiralicious_field_parser_data").
        should be_instance_of(Hash)
    end

    context "defining methods" do
      it "defines getter methods on the object it's called in" do
        @parsed_class.testfield.should == "Test Data"
      end

      it "prefixes a defined method with jira_ when the method already exists" do
        @parsed_class.jira_methods.should == "Test Data 2"
      end

      it "downcases java idiom method names" do
        @parsed_class.test_field.should == "Test Data 3"
      end

      it "converts nonword  to underscore" do
        @parsed_class.test_field_dash.should == "Test Data 4"
        @parsed_class.test_field_space.should == "Test Data 5"
      end
    end

    context "mashifying data" do
      it "makes hashes a mash" do
        @parsed_class.test_field_hash.should be_instance_of(Hashie::Mash)
      end

      it "recursively makes array elements mashes" do
        @parsed_class.test_field_array_with_hash.
          first.should be_instance_of(Hashie::Mash)
      end

      it "leaves array data alone when it's not a hash" do
        @parsed_class.test_field_array.should == ["Not a hash"]
      end
    end
  end
end
