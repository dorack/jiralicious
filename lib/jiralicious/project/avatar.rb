# encoding: utf-8
module Jiralicious
  class Project
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
        return if decoded_json.nil?
        if decoded_json.is_a? Hash
          decoded_json = properties_from_hash(decoded_json)
          super(decoded_json)
          parse!(decoded_json)
          self.each do |k, v|
            if v.is_a? Hash
              self[k] = self.class.new(v)
            elsif v.is_a? Array
              v.each_index do |i|
                v[i] = self.class.new(v[i]) if v[i].is_a? Hash
              end
              self[k] = v
            end
          end
          @loaded = true
        else
          i = 0
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

      class << self
        ##
        # Converts the temporary avatar to a real avatar
        #
        # [Arguments]
        # :key               (required)    project key
        #
        # :cropperWidth      (optional)    width of the avatar
        #
        # :cropperOffsetX    (optional)    X offset on image
        #
        # :cropperOffsetY    (optional)    Y offset on image
        #
        # :needsCropping     (optional)    boolean if it needs cropping
        #
        def post(key, options = {})
          fetch(method: :post, parent: true, parent_key: key, body: options)
        end

        ##
        # Update Avatar information
        #
        # [Arguments]
        # :key        (required)    project key
        #
        # :options    (optional)    not documented
        #
        def put(key, options = {})
          fetch(method: :put, parent: true, parent_key: key, body: options)
        end

        ##
        # Creates tempoary avatar
        #
        # [Arguments]
        # :key         (required)    project key
        #
        # :filename    (required)    file to upload
        #
        # :size        (required)    size of the file
        #
        def temporary(key, options = {})
          response = fetch(method: :post, parent: true, parent_key: key, key: "temporary", body: options)
          return self.new(response.parsed_response)
        end

        ##
        # Deletes or removes the avatar from the project
        #
        # [Arguments]
        # :key    (required)    project key
        #
        # :id     (required)    avatar id
        #
        def remove(key, id)
          fetch(method: :delete, body_to_params: true, parent: true, parent_key: key, key: id.to_s)
        end

        ##
        # Gets a list of available avatars
        #
        # [Arguments]
        # :key         (required)    project key
        #
        def avatars(key, options = {})
          response = fetch(method: :get, url: "#{Jiralicious.rest_path}/#{parent_name}/#{key}/#{endpoint_name}s/", body_to_params: true, body: options)
          return self.new(response.parsed_response)
        end
      end
    end
  end
end
