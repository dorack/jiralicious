# encoding: utf-8
module Jiralicious
  ##
  # The Field class is used in multiple classes as a support object. This class
  # is designed as a Object Oriented Method of viewing the Jira JSON/Hash.
  #
  class Field < Jiralicious::Base
    ##
    # Initialization Method
    # 
    # Builds the dynamic Field object from either a Hash or Array. The decoded JSON object can be nested
    # as deep as necessary but it is recommended that JSON objects are no deeper then 5 levels maximum.
    #
    def initialize(decoded_json, default = nil, &blk)
      @loaded = false
      if decoded_json.is_a? Hash
        decoded_json = properties_from_hash(decoded_json)
        super(decoded_json)
        parse!(decoded_json)
        self.each do |k, v|
          if v.is_a? Hash
            self[k] = self.class.new(v)
          elsif v.is_a? Array
            v.each_index do |i|
              if v[i].is_a? Hash
                v[i] = self.class.new(v[i])
              end
            end
            self[k] = v
          end
        end
        @loaded = true
      else
        decoded_json.each do |list|
          if numeric? list['id']
            id =  :"id_#{list['id']}"
          else
            id = :"#{list['id']}"
          end
          self.class.property id
          out self.class.new(list)
          self.merge!({id => out})
        end
      end
    end
  end
end
