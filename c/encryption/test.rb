#!/usr/bin/ruby

require 'pathname'
require 'base64'
require 'fileutils'

INFILE = "infile"
OUTFILE = "outfile"

def write(content)
    File.open("infile", 'w') do |f|
        f.puts content
    end
end

def read
    IO.read("outfile")
end

def clean
    %x{rm -f #{INFILE}}
    %x{rm -f #{OUTFILE}}
end

def prep
    %x{touch #{INFILE}}
    %x{touch #{OUTFILE}}
end

def test_encrypt(plaintext)
    puts "Encrypting #{plaintext}"
    write(plaintext)
    output = %x{./main.o aes infile outfile}
    puts output
    encrypted = read
    puts "After encrypt, len = #{encrypted.length}"
    encoded = Base64.encode64(encrypted)
    puts "After encode: #{encoded}"
    puts "###########################################"
end

def main
    FileUtils.cd(Pathname.new(File.dirname(__FILE__)).realpath) do
        clean
        prep
        %x{make demo}
        test_encrypt("6afa31dba6598")
        test_encrypt("6afa31dba6599")
        clean
    end
end

main
