# encoding: utf-8
module Jiralicious
  class User
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
          each do |k, v|
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
        # :username          (required)    username to change
        #
        # :cropperWidth      (optional)    width of the avatar
        #
        # :cropperOffsetX    (optional)    X offset on image
        #
        # :cropperOffsetY    (optional)    Y offset on image
        #
        # :needsCropping     (optional)    boolean if it needs cropping
        #
        def post(username, options = {})
          options[:username] = username
          fetch(method: :post, parent_uri: "#{parent_name}/", body: options)
        end

        ##
        # Update Avatar information
        #
        # [Arguments]
        # :username   (required)    project key
        #
        # :options    (optional)    not documented
        #
        def put(username, options = {})
          options[:username] = username
          fetch(method: :put, parent_uri: "#{parent_name}/", body: options)
        end

        ##
        # Creates temporary avatar
        #
        # [Arguments]
        # :username    (required)    project key
        #
        # :filename    (optional)    file to upload
        #
        # :size        (optional)    size of the file
        #
        def temporary(username, options = {})
          options[:username] = username
          response = fetch(method: :post, parent_uri: "#{parent_name}/", key: "temporary", body: options)
          new(response.parsed_response)
        end

        ##
        # Deletes or removes the avatar from the project
        #
        # [Arguments]
        # :username    (required)    project key
        #
        # :id          (required)    avatar id
        #
        def remove(username, id)
          fetch(method: :delete, body_to_params: true, parent_uri: "#{parent_name}/", key: id.to_s, body: { username: username })
        end

        ##
        # Gets a list of avatars
        #
        # [Arguments]
        # :username    (required)    user name
        #
        def avatars(username, options = {})
          options[:username] = username
          response = fetch(method: :get, body_to_params: true, url: "#{Jiralicious.rest_path}/#{parent_name}/#{endpoint_name}s", body: options)
          new(response.parsed_response)
        end
      end
    end
  end
end
