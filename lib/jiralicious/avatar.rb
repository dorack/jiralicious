# encoding: utf-8
module Jiralicious
  ##
  # Avatars in the Project class.
  #
  class Avatar < Jiralicious::Base

    ##
    # Initialization Method
    #
    # [Arguments]
    # :decoded_json    (optional)    decoded json object
    #
    def initialize(decoded_json = nil)
      @loaded = false
      if !decoded_json.nil?
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
          i = 0;
          decoded_json.each do |list|
            if !list["id"].nil?
              if numeric? list["id"]
                id = :"id_#{list["id"]}"
              else
                id = :"#{list["id"]}"
              end
            else
              id = :"_#{i}"
              i += 1
            end
            self.class.property id
            self[id] = self.class.new(list)
          end
        end
      end
    end

    class << self

      ##
      # Gets a list of available avatars
      #
      # [Arguments]
      # :key         (required)    avatar type = Project or User
      #
      def system(key, options = {})
        response = fetch({ :method => :get, :key => "#{key}/system", :body => options })
        return self.new(response.parsed_response)
      end

      ##
      # Creates temporary avatar
      #
      # [Arguments]
      # :key         (required)    avatar type = Project or User
      #
      # :filename    (required)    file to upload
      #
      # :size        (required)    size of the file
      #
      def temporary(key, options = {})
        response = fetch({ :method => :post, :key => "#{key}/temporary", :body => options })
        return self.new(response.parsed_response)
      end

      ##
      # Updates the cropping on a temporary avatar
      #
      # [Arguments]
      # :key         (required)    avatar type = Project or User
      #
      # :cropperWidth       (optional)    width of the image
      #
      # :cropperOffsetX     (optional)    X Offset on image
      #
      # :cropperOffsety     (optional)    Y Offset on image
      #
      # :needsCropping      (optional)    Boolean if needs cropping
      #
      def temporary_crop(key, options = {})
        response = fetch({ :method => :post, :key => "#{key}/temporaryCrop", :body => options })
      end
    end
  end
end
