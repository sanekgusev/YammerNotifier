#!/usr/bin/ruby

class String
	def parametrize(hash)
		raise ArgumentError, 'Argument is not a hash' unless hash.respond_to? :collect
		"#{self}?".concat(hash.collect { |k, v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&'))
	end
end
