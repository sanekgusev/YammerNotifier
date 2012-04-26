#!/usr/bin/ruby

require 'unicode_utils/downcase'

class KeywordChecker

	def initialize(collection)
		raise ArgumentError, 'Argument is not a collection' unless collection.respond_to? :any?
		@collection = collection
	end

	def contains_any_keyword?(string)
		@collection.any? { |keyword| UnicodeUtils.downcase(string).include? keyword }
	end

end
