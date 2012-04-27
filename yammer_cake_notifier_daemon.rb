#!/usr/bin/ruby

require 'daemons'

working_directory = Dir.pwd

Daemons.run_proc('yammer_cake_notifier.rb') do
	Dir.chdir(working_directory)
	exec 'ruby yammer_cake_notifier.rb'
end
