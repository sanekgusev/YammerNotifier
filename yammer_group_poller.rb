#!/usr/bin/ruby

require 'oauth'
require 'json'
require 'active_support/core_ext/numeric/time'
require_relative 'parametrized_get'

class YammerGroupPoller

	def initialize(group_name, oauth_hash)
		create_access_token(oauth_hash)
		find_group_by_name(group_name) or raise 'Unable to find requested group'
	end

	def poll_indefinitely(poll_period)
		return unless block_given?
		loop do
			begin
				if (message_response_hash = get_most_recent_message_response)
					yield message_response_hash if Time.parse(message_response_hash['messages'].first['created_at']) >= poll_period.seconds.ago
				end
				sleep(poll_period)
			rescue => e
				puts e.message
				puts e.backtrace
			end
		end
	end

	private

	def create_access_token(oauth_hash)
		consumer=OAuth::Consumer.new(oauth_hash['consumer_key'],
									 							 oauth_hash['consumer_secret'],
									 							 site: 'https://www.yammer.com')
		@access_token = OAuth::AccessToken.new(consumer,
																					 oauth_hash['token'],
																					 oauth_hash['token_secret'])
	end

	def find_group_by_name(group_name)
		params = { letter: group_name[0, 1] }

		groups = JSON.parse(@access_token.get('/api/v1/groups.json'.parametrize(params)).body)

		@group_id = groups.find(-> { {} } ) { |group| group['name'] == group_name.to_s }['id']
	end

	def get_most_recent_message_response
		params = { threaded: :true, limit: :'1' }
		params[:newer_than] = @most_recent_message_id if @most_recent_message_id

		response = JSON.parse(@access_token.get("/api/v1/messages/in_group/#@group_id.json".parametrize(params)).body)

		if (most_recent_message_hash = response['messages'].first)
			if (new_message_id = most_recent_message_hash['id']) != @most_recent_message_id
				@most_recent_message_id = new_message_id
				return response
			end
		end
	end

end
