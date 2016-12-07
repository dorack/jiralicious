# encoding: utf-8
module Jiralicious
  ##
  # Parsing module contains all of the parser functionality
  #
  module Parsers
    ##
    # The FieldParser module is an extention that assists in
    # managing hash parsing and implementation.
    #
    module FieldParser
      ##
      # Parses an Array or Hash into the current class object.
      #
      # [Arguments]
      # :fields    (required)    fields to be parsed
      #
      def parse!(fields)
        begin
          fields = fields.to_h unless fields.is_a?(Hash)
        rescue
          raise ArgumentError
        end
        @jiralicious_field_parser_data = {}
        singleton = class << self; self end

        fields.each do |field, details|
          if details.is_a?(Hash)
            next if details["name"].nil?
            method_value = mashify(details["value"])
            method_name  = normalize(details["name"])
          else
            method_value = mashify(details)
            method_name = normalize(field)
          end

          if singleton.method_defined?(method_name)
            method_name = "jira_#{method_name}"
          end

          @jiralicious_field_parser_data[method_name] = method_value
          singleton.send :define_method, method_name do
            @jiralicious_field_parser_data[method_name]
          end
        end
      end

      private

      ##
      # Normalizes key names
      #
      # [Arguments]
      # :name    (required)    name to be normalized
      #
      def normalize(name)
        name.gsub(/(\w+)([A-Z].*)/, '\1_\2')
        .gsub(/\W/, "_")
        .downcase
      end

      ##
      # Converts Array or Hash to a Mash object
      #
      # [Arguments]
      # :data    (required)    data be be mashified
      #
      def mashify(data)
        if data.is_a?(Array)
          data.map { |d| mashify(d) }
        elsif data.is_a?(Hash)
          Hashie::Mash.new(data)
        else
          data
        end
      end
    end
  end
end
