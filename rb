#!/usr/bin/env ruby
require 'io/console'
require "#{File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__)}/lib/doing"
include Doing

def lines
  doing{STDIN.gets}.map{|l|l.chomp}
end

begin
  eval(ARGV.join(" "))
rescue Errno::EPIPE
rescue Interrupt
end
