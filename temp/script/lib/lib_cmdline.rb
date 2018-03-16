require 'optparse'
require 'set'

class CommandError < RuntimeError ; end

class CommandHandler

    def initialize
        @opt_parser = OptionParser.new
        @required_options = Set.new
        @opts = Hash.new
    end

    def add_opt(key, opt_def, desc, required=true)
        @opt_parser.on(opt_def, desc) do |value|
            puts "opt_def = #{opt_def}"
            raise CommandError, "Invalid option defination '#{opt_def}', should match the format --opt=VAR"\
                unless opt_def =~ /^\-\-[a-z_\-]+=[A-Z_]/
            @opts[key] = value
        end
        @required_options << key if required
    end

    def parse(args)
        missing_options = []
        @opt_parser.parse(args)
        @required_options.each do |option|
            missing_options << option if @opts[option].nil?
        end
        raise CommandError, "Missing required option #{missing_options}" unless missing_options.empty?
        @opts
    end
end

$cmd_handler = CommandHandler.new

def cmd_handler() $cmd_handler end

#
# Add an option, the option is requried by default
# Examples:
# 1) Add a key-value option
#    add_option(:workspace, "--workspace=WORKSPACE", "Specify workspace")
# 2) Add a Boolean option
#    add_option(:compile, "--[no-]compile", "Specify whether compiling is needed")
# 3) Add a non-required option
#    add_option(:workspace, "--workspace=WORKSPACE", "Specify workspace", false)
#
def add_option(key, opt_def, desc, required=true)
    cmd_handler.add_opt(key.to_sym, opt_def, desc, required)
end

#
# Parse received arguments to a Hash map
#
def parse_options(args)
    cmd_handler.parse(args)
end

#
# Execute the main logic of the script
#
def run
    opts = parse_options(ARGV)
    yield(opts)
rescue SystemExit => err
    exit(0)
rescue CommandError => err
    puts "#{err}"
    exit(1)
rescue Exception => err
    raise
end
