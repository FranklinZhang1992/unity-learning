#!/usr/bin/ruby

require 'pathname'
require 'base64'
require 'fileutils'

INFILE = "infile"
OUTFILE = "outfile"
IVFILE = "ivfile"

def write(content)
    File.open("infile", 'w') do |f|
        f.puts content
    end
end

def read(file)
    IO.read(file)
end

def clean
    %x{rm -f #{INFILE}}
    %x{rm -f #{OUTFILE}}
    %x{rm -f #{IVFILE}}
end

def prep
    %x{touch #{INFILE}}
    %x{touch #{OUTFILE}}
    %x{touch #{IVFILE}}
end

def test_encrypt(plaintext)
    puts "Encrypting #{plaintext}, len: #{plaintext.length}"
    write(plaintext)
    output = %x{./main.o aes #{INFILE} #{OUTFILE} #{IVFILE}}
    puts output
    encrypted = read(OUTFILE).chomp
    puts "After encrypt, len = #{encrypted.length}"
    encoded = Base64.encode64(encrypted).chomp
    puts "After encode: #{encoded}, len: #{encoded.length}"
    output = %x{./main.o -d aes #{OUTFILE} #{INFILE} #{IVFILE}}
    decrypted = read(INFILE).chomp
    puts "After decrypt: #{decrypted}"
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
