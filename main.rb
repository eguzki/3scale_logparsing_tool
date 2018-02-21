#!/usr/bin/env ruby

require 'parallel'
require './parser'
require './reducer'
require './ui'

ARGV.size == 1 || abort('error: no path specified')

File.directory?(ARGV[0]) || abort('error: path not found')

logfile_array = Dir.entries(ARGV[0]).select { |f| !File.directory? f }.map { |f| File.join(ARGV[0], f) }
logstats = Parallel.map(logfile_array) { |f| parse_logfile f }
res = reduce_logstats logstats
ui res
exit 0
