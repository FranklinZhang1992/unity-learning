#!/usr/bin/ruby
## Using ruby's standard OptionParser to get subcommand's in command line arguments
## Note you cannot do: opt.rb help command
## other options are commander, main, GLI, trollop...

# run it as
# ruby opt.rb --help
# ruby opt.rb foo --help
# ruby opt.rb foo -q
# etc

# Reference: https://gist.github.com/rkumar/445735

require 'optparse'

options = {}

subtext = <<HELP
Commonly used command are:
   foo :     does something awesome
   baz :     does something fantastic

See 'opt.rb COMMAND --help' for more information on a specific command.
HELP

global = OptionParser.new do |opts|
  opts.banner = "Usage: opt.rb [options] [subcommand [options]]"
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.separator ""
  opts.separator subtext
end
#end.parse!

def common_options(opts)
    opts.on("-c", "--common=COMMON", "common option") do |v|
      options[:common] = v
    end
end

subcommands = { 
  'foo' => OptionParser.new do |opts|
      opts.banner = "Usage: foo [options]"
      opts.on("-f", "--[no-]force", "force verbosely") do |v|
        options[:force] = v
      end
      common_options(opts)
   end,
   'baz' => OptionParser.new do |opts|
      opts.banner = "Usage: baz [options]"
      opts.on("-q", "--[no-]quiet", "quietly run ") do |v|
        options[:quiet] = v
      end
      common_options(opts)
   end
 }

 global.order!
 command = ARGV.shift
 subcommands[command].order!

 puts "Command: #{command} "
 p options
 puts "ARGV:"
 p ARGV
