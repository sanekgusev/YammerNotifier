#!/usr/bin/ruby

# originally found on http://wiki.openstreetmap.org/wiki/OAuth_ruby_examples
# obtain access token & secret for yammer.com and store it into yammer_auth.yaml

require 'oauth'
require 'yaml'

# Format of yammer_auth.yaml:
# consumer_key
# consumer_secret
# token
# token_secret

auth = { 'consumer_key' => 'your_key', 'consumer_secret' => 'your_secret' }

consumer = OAuth::Consumer.new(auth['consumer_key'],
                            	auth['consumer_secret'],
                              { site: 'https://www.yammer.com' }

request_token = consumer.get_request_token

puts "Visit the following URL, log in if you need to, and authorize the app"
puts request_token.authorize_url
puts "When you've authorized that token, enter the verifier code you are assigned:"
verifier = gets.strip
puts "Converting request token into access token..."
access_token = request_token.get_access_token( { oauth_verifier: verifier } )

auth['token'] = access_token.token
auth['token_secret'] = access_token.secret

File.open('yammer_auth.yaml', 'w') { |f| YAML.dump(auth, f) }

puts "Done. Have a look at auth.yaml to see what's there."
