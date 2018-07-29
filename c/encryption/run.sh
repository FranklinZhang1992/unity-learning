#!/usr/bin/ruby

require 'pathname'
require 'base64'
require 'fileutils'

class TestError < RuntimeError ; end

def generate(system_uuid, version)
    cmd = "encryptor_tool_#{version}.o"
    output = %x{./#{cmd} -e #{system_uuid}}.chomp
    unless $?.success?
        puts "[FAIL] Error exit code"
        exit(-1)
    end
    puts output
end

def run(version, count)
    FileUtils.cd(Pathname.new(File.dirname(__FILE__)).realpath) do
        system_uuid = "161a9d1c6b434e998e52e5be7356e438"
        puts "System UUID: #{system_uuid}"
        (0...count).each do
            generate(system_uuid, version)
            sleep 1.0/1000.0
        end
    end
end

def main
    if ARGV.nil? || ARGV.length == 0
        usage = <<EOT
Usage: ./run.sh <version> <test_count>
    <version>             v1 or v2
    <test_count>          test count
EOT
        puts usage
        exit(0)
    end
    version = ARGV[0].to_sym
    count = ARGV[1].to_i == 0 ? 1 : ARGV[1].to_i
    raise "Invalid version (expected: v1 or v2)" unless version == :v1 || version == :v2
    run(version, count)
end

begin
    main
rescue TestError => err
    puts "#{err}"
end

