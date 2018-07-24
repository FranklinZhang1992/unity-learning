#!/usr/bin/ruby

require 'pathname'
require 'base64'
require 'fileutils'

INFILE = "infile.tmp"
OUTFILE = "outfile.tmp"

ALGO = "blowfish"

def write(content)
    %x{echo -n '#{content}' > #{INFILE}}
end

def read(file)
    IO.read(file)
end

def clean
    %x{rm -f *.tmp}
end

# def prep
#     %x{touch #{INFILE}}
#     %x{touch #{OUTFILE}}
# end

def test_encrypt2(plaintext)
    write(plaintext)
    output = %x{./main_default.o #{ALGO} #{INFILE} #{OUTFILE} 2>&1}.chomp
    puts output
    # e64 = encode64
    # puts "#{e64}, len: #{e64.length}"
    output = %x{./main_default.o -d #{ALGO} #{OUTFILE} #{INFILE}}
    # puts output
    decrypted = read(INFILE)
    puts "[FAIL]" unless decrypted == plaintext
    puts "###########################################"
end

def generate(system_uuid)
    part1 = system_uuid[0, 9]
    timestamp = "#{(Time.now.to_f * 1000).to_i}"
    part2 = timestamp.reverse[0, 4]
    puts "timestamp: #{timestamp}"
    code = "#{part1}#{part2}"
    puts "Raw code: #{code}"
    %x{echo -n '#{code}' > #{INFILE}}
    output = %x{./encryptor.o #{ALGO} #{INFILE} #{OUTFILE} 2>&1}.chomp
    unless $?.success?
        puts "[FAIL] Error exit code"
        exit(-1)
    end
    encoded = nil
    if output =~ /Encoded: ([0-9A-Za-z]*), len: [0-9*]/
        encoded = $1
        # puts "encoded: #{encoded}, len: #{encoded.length}"
        formatted = encoded.scan(/.{1,6}/).join('-')
        puts "Cooked code: #{formatted}, len: #{formatted.length}"
    else
        puts "[FAIL] Wrong output"
        exit(-1)
    end
end

def run(count)
    FileUtils.cd(Pathname.new(File.dirname(__FILE__)).realpath) do
        clean
        system_uuid = "161a9d1c6b434e998e52e5be7356e438"
        puts "system_uuid: #{system_uuid}"
        (0...count).each do
            generate(system_uuid)
            sleep 1.0/1000.0
        end
        clean
    end
end

def main
    if ARGV.nil? || ARGV.length == 0
        puts "Usage: ./run.sh <test count>"
        exit(0)
    end
    count = ARGV[0].to_i
    run(count)
end

main
