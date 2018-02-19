#!/usr/bin/env ruby

require 'parallel'
require './parser'
require './reducer'

ARGV.size == 1 || abort('error: no path specified')

File.directory?(ARGV[0]) || abort('error: path not found')

logfile_array = Dir.entries(ARGV[0]).select { |f| !File.directory? f }.map { |f| File.join(ARGV[0], f) }
logstats = Parallel.map(logfile_array) { |f| parse_logfile f }
reduce_logstats logstats

exit 0
