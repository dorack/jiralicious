# encoding: utf-8
module Jiralicious
	class Issue
		class Comment < Jiralicious::Base

			attr_accessor :jira_key

			def initialize(decoded_json = nil, default = nil, &blk)
				if (decoded_json != nil)
					properties_from_hash(decoded_json)
					super(decoded_json)
					parse!(decoded_json)
				end
			end

			class << self
				def find_by_key(key, options = {})
					response = fetch({:parent => parent_name, :parent_key => key})
					a = new(response)
					a.jira_key = key
					return a
				end

				def find_by_key_and_id(key, id, options = {})
					response = fetch({:parent => parent_name, :parent_key => key, :key => id})
					a = new(response)
					a.jira_key = key
					return a
				end

				def add(comment, key)
					fetch({:method => :post, :body => comment, :parent => parent_name, :parent_key => key})
				end

				def edit(comment, key, id)
					fetch({:method => :put, :key => id, :body => comment, :parent => parent_name, :parent_key => key})
				end

				def remove(key, id)
					fetch({:method => :delete, :body_to_params => true, :key => id, :parent => parent_name, :parent_key => key})

				end
			end

			def find_by_id(id, options = {})
				self.class.find_by_key_and_id(@jira_key, id)
			end

			def add(comment)
				self.class.add(comment, @jira_key)
			end

			def edit(comment)
				self.class.edit(comment, @jira_key, self.id)
			end

			def remove(id = self.id)
				self.class.remove(@jira_key, id)
			end
		end
	end
end
