# To change this template, choose Tools | Templates
# and open the template in the editor.
module Jiralicious
	class CustomFieldOption < Jiralicious::Base
		def initialize(decoded_json, default = nil, &blk)
			@loaded = false
			if decoded_json.is_a? Hash
				properties_from_hash(decoded_json)
				super(decoded_json)
				parse!(decoded_json)
				@loaded = true
			end
		end

		class << self
			def endpoint_name
				"customFieldOption"
			end

			def find(id, options = {})
				response = fetch({:key => id})
				response.parsed_response['id'] = id
				new(response.parsed_response)
			end
		end
	end
end
