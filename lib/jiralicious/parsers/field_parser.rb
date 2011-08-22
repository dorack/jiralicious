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
          method_value = mashify(details["value"])
          method_name  = details["name"].gsub(/(\w+)([A-Z].*)/, '\1_\2').
            gsub(/\W/, "_").
            downcase

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
