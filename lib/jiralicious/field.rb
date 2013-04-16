# To change this template, choose Tools | Templates
# and open the template in the editor.
module Jiralicious
	class Field < Jiralicious::Base

		def initialize(decoded_json, default = nil, &blk)
			@loaded = false
			if decoded_json.kind_of? Hash
				properties_from_hash(decoded_json)
				super(decoded_json)
				parse!(decoded_json)
				self.each do |k, v|
					if v.kind_of? Hash
						self[k] = self.class.new(v)
					elsif v.kind_of? Array
						v.each_index do |i|
							if v[i].kind_of? Hash
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
