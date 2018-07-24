#!/usr/bin/ruby

require 'pathname'
require 'base64'
require 'fileutils'

INFILE = "infile"
OUTFILE = "outfile"
IVFILE = "ivfile"
TMPFILE = "tmpfile"

ALGO = "blowfish"

def write(content)
    %x{echo '#{content}' > #{INFILE}}
    # File.open("infile", 'w') do |f|
    #     f.puts content
    # end
end

def read(file)
    IO.read(file)
end

def clean
    %x{rm -f #{INFILE}}
    %x{rm -f #{OUTFILE}}
    %x{rm -f #{IVFILE}}
    %x{rm -f #{TMPFILE}}
end

def prep
    %x{touch #{INFILE}}
    %x{touch #{OUTFILE}}
    %x{touch #{IVFILE}}
    %x{touch #{TMPFILE}}
end

def encode64
    encrypted = read(OUTFILE).chomp
    encoded = Base64.encode64(encrypted).chomp
end

def encode32
    output = %x{java -jar Base32.jar -e #{OUTFILE} #{TMPFILE}}.chomp
    encoded = read(TMPFILE).chomp
end

def test_encrypt(plaintext)
    puts "Encrypting #{plaintext}, len: #{plaintext.length}"
    # write(plaintext)
    output = %x{./main.o #{ALGO} #{plaintext} 2>&1}.chomp
    puts output
    encrypted = nil
    if output =~ /After encode: ([0-9A-Z]*), len: [0-9]*/
        encrypted = $1
    end
    output = %x{./main.o -d #{ALGO} #{encrypted}}
    puts output
    decrypted = nil
    if output =~ /After decrypt: ([0-9A-Za-z]*), len: [0-9]*/
        decrypted = $1
    end
    puts "[FAIL]" unless decrypted == plaintext
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
