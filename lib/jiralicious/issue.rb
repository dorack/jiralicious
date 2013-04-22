# encoding: utf-8
module Jiralicious
	class Issue < Jiralicious::Base

		property :jira_key, :from  => :key
		property :expand
		property :jira_self, :from => :self
		property :fields
		property :transitions
		property :id
		attr_accessor :fields
		attr_accessor :comments
		attr_accessor :watchers
		attr_accessor :createmeta
		attr_accessor :editmeta

		### Initialization ###
		def initialize(decoded_json = nil, default = nil, &blk)
			@loaded = false
			if (decoded_json != nil)
				super(decoded_json)
				parse!(decoded_json["fields"])
				if default.nil?
					@fields = Fields.new(self['fields']) if self['fields']
					@comments = Comment.find_by_key(self.jira_key)
					@watchers = Watchers.find_by_key(self.jira_key)
					@loaded = true
				end
			end
			@fields = Fields.new if @fields.nil?
			@comments = Comment.new if @comments.nil?
			@watchers = Watchers.new if @watchers.nil?
			@createmeta = nil
			@editmeta = nil
		end

		def load(decoded_hash, default = nil)
			decoded_hash.each do |k,v|
				self[:"#{k}"] = v
			end
			if default.nil?
				parse!(self['fields'])
				@fields = Fields.new(self['fields']) if self['fields']
				@comments = Comment.find_by_key(self.jira_key)
				@watchers = Watchers.find_by_key(self.jira_key)
				@loaded = true
			else
				parse!(decoded_hash)
			end
		end

		def reload
			load(self.class.find(self.jira_key, {:reload => true}).parsed_response)
		end


		### Class Methods ###
		class << self
			def assignee(name, key)
				name = {"name" => name} if name.is_a? String
				fetch({:method => :put, :key => key, :body => name})
			end

			def create(issue)
				fetch({:method => :post, :body => issue})
			end

			def remove(key, options = {})
				fetch({:method => :delete, :body_to_params => true, :key => key, :body => options})
			end

			def update(issue, key)
				fetch({:method => :put, :key => key, :body => issue})
			end

			def createmeta(projectkeys, issuetypeids = nil)
				response = fetch({:body_to_params => true, :key => "createmeta", :body => {:expand => "projects.issuetypes.fields.", :projectKeys => projectkeys, :issuetypeIds => issuetypeids}})
				Field.new(response.parsed_response)
			end

			def editmeta(key)
				response = fetch({:key => "#{key}/editmeta"})
				Field.new(response.parsed_response)
			end

			def get_transitions(transitions_url)
				Jiralicious.session.request(:get, transitions_url, :handler => handler)
			end

			def transition(transitions_url, data)
				Jiralicious.session.request(:post, transitions_url,
					:handler => handler,
					:body => data.to_json)
			end
		end

		### Public Classes ###

		def assignee(name)
			self.class.assignee(name, self.jira_key)
		end

		def remove(options = {})
			self.class.remove(self.jira_key, options)
		end

		def createmeta
			if @createmeta.nil?
				@createmeta = self.class.createmeta(self.jira_key.split("-")[0])
			end
			@createmeta
		end

		def editmeta
			if @editmeta.nil?
				@editmeta = self.class.editmeta(self.jira_key)
			end
			@editmeta
		end

		def save
			if loaded?
				self.class.update(@fields.format_for_update, self.jira_key)
				key = self.jira_key
			else
				response = self.class.create(@fields.format_for_create)
				key = response['key']
			end
			load(self.class.find(key, {:reload => true}).parsed_response)
		end
	end
end
