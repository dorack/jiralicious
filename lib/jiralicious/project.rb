# To change this template, choose Tools | Templates
# and open the template in the editor.
module Jiralicious
	class Project < Jiralicious::Base
		
		attr_accessor :issues

		### Initialization ###
		def initialize(decoded_json, default = nil, &blk)
			@loaded = false
			if decoded_json.is_a? Hash
				properties_from_hash(decoded_json)
				super(decoded_json)
				parse!(decoded_json)
				@loaded = true
			else
				decoded_json.each do |list|
					self.class.property :"#{list['key']}"
					self.merge!({list['key'] => self.class.find(list['key'])})
				end
			end
		end

		class << self
			def issue_list(key)
				response = Jiralicious.search("project=#{key}", {:fields => ["id", "key"]})
				i_out = Issue.new
				response.issues_raw.each do |issue|
					i_out.class.property :"#{issue["key"].gsub("-", "_")}"
					t = Issue.new
					i_out[issue["key"].gsub("-", "_")] = t.load(issue, true)
				end
				i_out
			end
		end

		def issues
			if @issues == nil
				@issues = self.class.issue_list(self.key)
			end
			return @issues
		end
	end
end
