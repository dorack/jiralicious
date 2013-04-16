# To change this template, choose Tools | Templates
# and open the template in the editor.
module Jiralicious
	class Issue
		class Transitions < Jiralicious::Base

			attr_accessor :meta

			def initialize(decoded_json, default = nil, &blk)
				puts "\n"; puts decoded_json.inspect; puts "\n"
				@loaded = false
				@meta = nil
				if decoded_json.kind_of? Hash
					properties_from_hash(decoded_json)
					super(decoded_json)
					parse!(decoded_json)
					@loaded = true
				else
					self.class.property :jira_key
					self.jira_key = default
					decoded_json.each do |list|
						self.class.property :"id_#{list['id']}"
						self.merge!({"id_#{list['id']}" => self.class.new(list)})
					end
				end
			end

			class << self

				def find(key, options = {})
					response = fetch({:parent => parent_name, :parent_key => key})
					response.parsed_response['transitions'].each do |t|
						t['jira_key'] = key
					end
					a = new(response.parsed_response['transitions'], key)
					return a
				end

				def find_by_key_and_id(key, id, options = {})
					response = fetch({:key => id, :parent => parent_name, :parent_key => key})
					response.parsed_response['jira_key'] = key
					a = new(response.parsed_response['transitions'])
					return a
				end

				def go(key, id, options = {})
					transition = {"transition" => {"id" => id}}
					if options[:comment].kind_of? String
						transition.merge!({"update" => {"comment" => [{"add" => {"body" => options[:comment].to_s}}]}})
					elsif options[:comment].kind_of? Jiralicious::Issue::Fields
						transition.merge!(options[:comment].format_for_update)
					elsif options[:comment].kind_of? Hash
						transition.merge!({"update" => options[:comment]})
					end
					if options[:fields].kind_of? Jiralicious::Issue::Fields
						transition.merge!(options[:fields].format_for_create)
					elsif options[:fields].kind_of? Hash
						transition.merge!({"fields" => options[:fields]})
					end
					fetch({:method => :post, :parent => parent_name, :parent_key => key, :body => transition})
				end

				def meta(key, id, options = {})
					response = fetch({:method => :get, :parent => parent_name, :parent_key => key, :body_to_params => true,
		:body => {"transitionId" => id, "expand" => "transitions.fields"}})
					response.parsed_response['transitions'].each do |t|
						t['jira_key'] = key
					end
					a = (options[:return].nil?) ?  new(response.parsed_response['transitions'], key) : response
					return a
				end

				alias :find_all :find
			end

			def all
				self.class.all(self.jira_key) if self.jira_key
			end

			def go(options = {})
				self.class.go(self.jira_key, self.id, options)
			end

			def meta
				if @meta.nil?
					l = self.class.meta(self.jira_key, self.id, {:return => true})
					@meta = Field.new(l.parsed_response['transitions'].first)
				end
				@meta
			end
		end
	end
end
