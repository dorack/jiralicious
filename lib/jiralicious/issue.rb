# encoding: utf-8
module Jiralicious
	##
	# The Issue class rolls up all functionality of issues from jira. This class contains methods to manage
	# Issues from Ruby via the API. Several child classes are added in order to facilitate several different
	# aspects of managing the issues.
	#
	class Issue < Jiralicious::Base

		# Provides access to the Jira Key field
		property :jira_key, :from  => :key
		# Provides access to the expand fields
		property :expand
		# Provides access to the self string
		property :jira_self, :from => :self
		# Provides access to the field list
		property :fields
		# Provides access to transitions
		property :transitions
		# Provides access to the Jira id
		property :id
		# Contains the Fields Class
		attr_accessor :fields
		# Contains the Comments Class
		attr_accessor :comments
		# Contains the Watchers Class
		attr_accessor :watchers
		# Contains the createmeta
		attr_accessor :createmeta
		# Contains the editmeta
		attr_accessor :editmeta

		# Initialization Method
		def initialize(decoded_json = nil, default = nil, &blk)
			@loaded = false
			if (!decoded_json.nil?)
				super(decoded_json)
				parse!(decoded_json["fields"])
				if default.nil?
					@fields = Fields.new(self['fields']) if self['fields']
					@comments = Comment.find_by_key(self.jira_key)
					@watchers = Watchers.find_by_key(self.jira_key)
					@transitions = Transitions.new(self.jira_key)
					@loaded = true
				end
			end
			@fields = Fields.new if @fields.nil?
			@comments = Comment.new if @comments.nil?
			@watchers = Watchers.new if @watchers.nil?
			@transitions = Transitions.new if @transitions.nil?
			@createmeta = nil
			@editmeta = nil
		end

		##
		# Imports all data from a decoded hash. This function is used when a blank
		# issue is created but needs to be loaded from a JSON string at a later time.
		#
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

		##
		# Forces the Jira Issue to reload with current or updated
		# information. This method is used in lazy loading methods.
		#
		def reload
			load(self.class.find(self.jira_key, {:reload => true}).parsed_response)
		end

		class << self
			##
			# Adds specified assignee to the Jira Issue.
			#
			def assignee(name, key)
				name = {"name" => name} if name.is_a? String
				fetch({:method => :put, :key => "#{key}/assignee", :body => name})
			end

			##
			# Creates a new issue. This method is not recommended
			# for direct access but is provided for advanced users.
			#
			def create(issue)
				fetch({:method => :post, :body => issue})
			end

			##
			# Removes/Deletes the Issue from the Jira Project. It is not recommended to delete issues however the
			# functionality is provided. It is recommended to override this function to throw an error or warning
			# to maintain data integrity in systems that do not allow deleting from a remote location.
			#
			def remove(key, options = {})
				fetch({:method => :delete, :body_to_params => true, :key => key, :body => options})
			end

			##
			# Updates the specified issue based on the provided HASH. It is not recommended
			# to access this method directly but is provided for advanced users.
			#
			def update(issue, key)
				fetch({:method => :put, :key => key, :body => issue})
			end

			##
			# Retrieves the create meta for the Jira Project based on Issue Types.
			# Can be used to validate or filter create requests to minimize errors.
			#
			def createmeta(projectkeys, issuetypeids = nil)
				response = fetch({:body_to_params => true, :key => "createmeta", :body => {:expand => "projects.issuetypes.fields.", :projectKeys => projectkeys, :issuetypeIds => issuetypeids}})
				return Field.new(response.parsed_response)
			end

			##
			# Retrieves the edit meta for the Jira Issue. Can be used
			# to validate or filter create requests to minimize errors.
			#
			def editmeta(key)
				response = fetch({:key => "#{key}/editmeta"})
				response.parsed_response["key"] = key
				Field.new(response.parsed_response)
			end

			##
			# Legacy method to retrieve transitions manually.
			#
			def get_transitions(transitions_url)
				Jiralicious.session.request(:get, transitions_url, :handler => handler)
			end

			##
			# Legacy method to process transitions manually.
			#
			def transition(transitions_url, data)
				Jiralicious.session.request(:post, transitions_url,
					:handler => handler,
					:body => data.to_json)
			end
		end

		##
		# Method to assign an assignee by name in a current issue.
		#
		def set_assignee(name)
			self.class.assignee(name, self.jira_key)
		end

		##
		# Method to remove or delete the current issue.
		#
		def remove(options = {})
			self.class.remove(self.jira_key, options)
		end

		##
		# Retrieves the create meta for the Jira Project based on Issue Types.
		# Can be used to validate or filter create requests to minimize errors.
		#
		def createmeta
			if @createmeta.nil?
				@createmeta = self.class.createmeta(self.jira_key.split("-")[0])
			end
			@createmeta
		end

		##
		# Retrieves the edit meta for the Jira Issue. Can be used
		# to validate or filter create requests to minimize errors.
		#
		def editmeta
			if @editmeta.nil?
				@editmeta = self.class.editmeta(self.jira_key)
			end
			@editmeta
		end

		##
		# Saves the current Issue but does not update itself.
		#
		def save
			if loaded?
				self.class.update(@fields.format_for_update, self.jira_key)
				key = self.jira_key
			else
				response = self.class.create(@fields.format_for_create)
				key = response.parsed_response['key']
			end
			return key
		end

		##
		# Saves the current Issue and reloads to ensure it is upto date.
		#
		def save!
			load(self.class.find(save, {:reload => true}).parsed_response)
		end
	end
end
