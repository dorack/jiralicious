# encoding: utf-8
module Jiralicious
  class Issue
    class Fields
      attr_accessor :fields_update
      attr_accessor :fields_current

      def initialize(fc = nil)
        @fields_current = (fc == nil) ? Hash.new : fc
        @fields_update = Hash.new
      end

      def count
        return @fields_update.count
      end

      def length
        return @fields_update.length
      end

      def add_comment(comment)
        if !(@fields_update['comment'].type == Array)
          @fields_update['comment'] = Array.new
        end
        @fields_update['comment'].push({"add" => {"body" => comment}})
      end

      def append_s(field, value)
        if (@fields_update[field] == nil)
          @fields_update[field] = @fields_current[field] unless @fields_current.nil?
          @fields_update[field] ||= ""
        end
        @fields_update[field] += " " + value.to_s
      end

      def append_a(field, value)
        @fields_update[field] = @fields_current[field] if (@fields_update[field] == nil)
        @fields_update[field] = Array.new if !(@fields_update[field].is_a? Array)
        if value.is_a? String
          @fields_update[field].push(value)
        else
          @fields_update[field] = @fields_update[field].concat(value)
        end
      end

      def append_h(field, hash)
        @fields_update[field] = @fields_current[field] if (@fields_update[field] == nil)
        @fields_update[field] = Hash.new if !(@fields_update[field].is_a? Hash)
        @fields_update[field].merge!(hash)
      end

      def set(field, value)
        @fields_update[field] = value
      end

      def set_name(field, value)
        @fields_update[field] = {"name" => value}
      end

      def set_id(field, value)
        @fields_update[field] = {"id" => value}
      end

      def set_current(fc)
        @fields_current = fc if fc.type == Hash
      end

      def current
        return @fields_current
      end

      def updated
        return @fields_update
      end

      def format_for_update
        up = Hash.new
        @fields_update.each do |k, v|
          if k == "comment"
            up[k] = v
          else
            up[k] = [{"set" => v}]
          end
        end
        return {"update" => up}
      end

      def format_for_create
        return {"fields" => @fields_update}
      end
    end
  end
end
