# encoding: utf-8
module Jiralicious
  module Parsers
    module FieldParser
      def parse!(fields)
        unless fields.is_a?(Hash)
          raise ArgumentError
        end
        @jiralicious_field_parser_data = {}
        singleton = class << self; self end

        fields.each do |field, details|
          next if details["name"].nil?
          method_name = details["name"].gsub(/(\w+)([A-Z].*)/, '\1_\2').
            gsub(/-\ /, "_").
            downcase

          if singleton.method_defined?(method_name)
            method_name = "jira_#{method_name}"
          end

          @jiralicious_field_parser_data[method_name] = details["value"]
          singleton.send :define_method, method_name do
            @jiralicious_field_parser_data[method_name]
          end
        end
      end
    end
  end
end
