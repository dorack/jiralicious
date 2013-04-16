# To change this template, choose Tools | Templates
# and open the template in the editor.
module Jiralicious
	class Issue
		class Watchers < Jiralicious::Base

			attr_accessor :jira_key

			def initialize(decoded_json = nil, default = nil, &blk)
				if (decoded_json != nil)
					properties_from_hash(decoded_json)
					super(decoded_json)
					parse!(decoded_json)
				end
			end

			class << self
				def find_by_key(key)
					response = fetch({:parent => parent_name, :parent_key => key})
					a = new(response)
					a.jira_key = key
					return a
				end

				def add(name, key)
					fetch({:method => :post, :body => name, :body_override => true, :parent => parent_name, :parent_key => key})
				end

				def remove(name, key)
					fetch({:method => :delete, :body_to_params => true, :body => {:username => name}, :parent => parent_name, :parent_key => key})
				end
			end

			def find
				self.class.find_by_key(@jira_key)
			end

			def add(name)
				self.class.add(name, @jira_key)
			end

			def remove(name)
				self.class.remove(name, @jira_key)
			end
		end
	end
end
