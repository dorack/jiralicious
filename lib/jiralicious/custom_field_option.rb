# encoding: utf-8
module Jiralicious
	##
	# The CustomFieldOption provides a list of available custom field options. This method is
	# used in lazy loading and can be used to validate options prior to updating the issue.
	#
	class CustomFieldOption < Jiralicious::Base

		##
		# Initialization Method
		#
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
			##
			# Overrides the auto-generated endpoint_name from Base.
			# This is necessary due to lower camel case naming convention.
			#
			def endpoint_name
				"customFieldOption"
			end

			##
			# Retrieves the options based on the ID
			#
			def find(id, options = {})
				response = fetch({:key => id})
				response.parsed_response['id'] = id
				new(response.parsed_response)
			end
		end
	end
end
