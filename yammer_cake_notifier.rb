#!/usr/bin/ruby

require 'yaml'
require 'boxcar_api'
require 'active_support/core_ext/numeric/time'
require_relative 'yammer_group_poller'
require_relative 'keyword_checker'

POLL_PERIOD = 3.minutes


boxcar_auth = YAML.load(File.open('boxcar_auth.yaml'))

boxcar_provider = BoxcarAPI::Provider.new(boxcar_auth['key'],
										  boxcar_auth['key_secret'])

keyword_checker = KeywordChecker.new(YAML.load(File.open('cake_keywords.yaml')))

poller = YammerGroupPoller.new('kitchen', YAML.load(File.open('yammer_auth.yaml')))

poller.poll_indefinitely(POLL_PERIOD) do |response|
	message = response['messages'].first
	plain_message_body = message['body']['plain']

	next unless keyword_checker.contains_any_keyword? plain_message_body

	user_name = response['references'].find { |reference| reference['id'] == message['sender_id'] }['full_name']
	puts "#{user_name}: #{plain_message_body}"
	boxcar_provider.broadcast("#{user_name}: #{plain_message_body}")
end
