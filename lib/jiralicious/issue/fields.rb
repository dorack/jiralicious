# encoding: utf-8
module Jiralicious
  class Issue
    ##
    # The Fields class provides functionality to the Issue class that allows it to easily
    # update or create issues. The class retains the original  and the proposed information
    # which could be used for cross validation prior to posting an update.
    #
    class Fields
      # The fields that will be updated or created
      attr_accessor :fields_update
      # The current fields when a ticket was loaded
      attr_accessor :fields_current

      ##
      # Initialization Method
      #
      def initialize(fc = nil)
        @fields_current = (fc == nil) ? Hash.new : fc
        @fields_update = Hash.new
      end

      ##
      # Returns the count of fields being updated.
      #
      def count
        return @fields_update.count
      end

      ##
      # Returns the length of fields being updated.
      #
      def length
        return @fields_update.length
      end

      ##
      # Adds a comment to the field list
      #
      def add_comment(comment)
        if !(@fields_update['comment'].is_a? Array)
          @fields_update['comment'] = Array.new
        end
        @fields_update['comment'].push({"add" => {"body" => comment}})
      end

      ##
      # Appends the current String with the provided value
      #
      def append_s(field, value)
        if (@fields_update[field] == nil)
          @fields_update[field] = @fields_current[field] unless @fields_current.nil?
          @fields_update[field] ||= ""
        end
        @fields_update[field] += " " + value.to_s
      end

      ##
      # Appends the current Array with the provided value
      #
      def append_a(field, value)
        @fields_update[field] = @fields_current[field] if (@fields_update[field] == nil)
        @fields_update[field] = Array.new if !(@fields_update[field].is_a? Array)
        if value.is_a? String
          @fields_update[field].push(value) unless @fields_update[field].include? value
        else
          @fields_update[field] |= value
        end
      end

      ##
      # Appends the current Hash with the provided value
      #
      def append_h(field, hash)
        @fields_update[field] = @fields_current[field] if (@fields_update[field] == nil)
        @fields_update[field] = Hash.new if !(@fields_update[field].is_a? Hash)
        @fields_update[field].merge!(hash)
      end

      ##
      # Sets the field key with the provided value.
      #
      def set(field, value)
        @fields_update[field] = value
      end

      ##
      # Sets the field with a name hash.
      # This is necessary for some objects in Jira.
      #
      def set_name(field, value)
        @fields_update[field] = {"name" => value}
      end

      ##
      # Sets the field with a id hash.
      # This is necessary for some objects in Jira.
      #
      def set_id(field, value)
        @fields_update[field] = {"id" => value}
      end
      ##
      # Fills the fields_current object with the provided Hash.
      #
      def set_current(fc)
        @fields_current = fc if fc.type == Hash
      end

      ##
      # Returns the current fields object
      #
      def current
        return @fields_current
      end

      ##
      # Returns the updated fields object
      #
      def updated
        return @fields_update
      end

      ##
      # Formats the fields_update object correctly
      # for Jira to perform an update request.
      #
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

      ##
      # Formats the fields_update object correctly
      # for Jira to perform an create request.
      #
      def format_for_create
        return {"fields" => @fields_update}
      end
    end
  end
end
