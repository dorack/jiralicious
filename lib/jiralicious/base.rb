# To change this template, choose Tools | Templates
# and open the template in the editor.
require "uri"
module Jiralicious
	class Base < Hashie::Trash
		include Jiralicious::Parsers::FieldParser

		attr_accessor :loaded

		### Trash Extention Methods ###
		def properties_from_hash(hash)
			hash.each do |k, v|
				ko = k
				k = k.gsub("-", "_")
				k = "_#{k.to_s}" if k =~ /^\d/
				self.class.property :"#{k}"
				hash.delete(ko)
				hash[k] = v
			end
			hash
		end

		### Class Methods ###
		class << self
			def find(key, options = {})
				response = fetch({:key => key})
				if options[:reload] == true
					response
				else
					new(response.parsed_response) unless options[:reload]
				end
			end

			def find_all
				response = fetch()
				new(response)
			end

			def endpoint_name
				self.name.split('::').last.downcase
			end

			def parent_name
				arr = self.name.split('::')
				arr[arr.length-2].downcase
			end

			def fetch(options = {})
				options[:method] = :get unless [:get, :post, :put, :delete].include?(options[:method])
				options[:parent_uri] = "#{parent_name}/#{options[:parent_key]}/" unless options[:parent].nil?
				if !options[:body_override]
					options[:body_uri] = (options[:body].is_a? Hash) ? options[:body] : {:body => options[:body]}
				else
					options[:body_uri] = options[:body]
				end
				if options[:body_to_params]
					options[:params_uri] = "?#{options[:body].to_params}" unless options[:body].nil? || options[:body].empty?
					options[:body_uri] = nil
				end
				options[:url_uri] = options[:url].nil? ? "#{Jiralicious.rest_path}/#{options[:parent_uri]}#{endpoint_name}/#{options[:key]}#{options[:params_uri]}" : options[:url]
				Jiralicious.session.request(options[:method], options[:url_uri], :handler => handler, :body => options[:body_uri].to_json)
			end

			def handler
				Proc.new do |response|
					case response.code
					when 200..204
						response
					when 400
						raise Jiralicious::TransitionError.new(response['errorMessages'].join('\n'))
					when 404
						raise Jiralicious::IssueNotFound.new(response['errorMessages'].join('\n'))
					else
						raise Jiralicious::JiraError.new(response['errorMessages'].join('\n'))
					end
				end
			end

			alias :all :find_all
		end

		### Instance Methods ###
		def endpoint_name
			self.class.endpoint_name
		end

		def parent_name
			self.class.parent_name
		end

		def all
			self.class.all
		end

		def loaded?
			self.loaded
		end

		def reload
		end

		def method_missing(meth, *args, &block)
			if !loaded?
				self.loaded = true
				reload
				self.send(meth, *args, &block)
			else
				super
			end
		end

		def numeric?(object)
			true if Float(object) rescue false
		end
	end
end
