require 'tempfile'
require 'pathname'

class FileManager

    def initialize(encoding)
        Encoding.find(encoding)
        @encoding = encoding
    end

    def file_encoding(file)
        output = %x{file --mime-encoding #{file}}.chomp
        regexp = Regexp.new("#{file}: (\\S+)")
        matched = output.match(regexp)
        encoding = matched[1] if matched
    end

    def open(file, &blk)
        File.open(file, "rb:#{file_encoding(file)}") do |f|
            while line = f.gets
                line = line.nil? ? nil : line.encode(@encoding)
                blk.call(line)
            end
        end
    end

    def read(file)
        content = ""
        open(file) do |line|
            content << line
        end
        content
    end

    def write(file, content)
        temp_file = Tempfile.new("#{File.basename(file)}", Pathname.new(File.dirname(file)).realpath, :encoding => @encoding)
        begin
            temp_file.puts content
            temp_file.flush
            FileUtils.cp(temp_file.path, file)
        ensure
            temp_file.close!
        end
    end
end

file_manager = FileManager.new("UTF-8")
tmp_file = "/tmp/test"

content = <<EOF
ααββ
ののの
测试
aaa
bbb
ccc
EOF

file_manager.write(tmp_file, content)

content = ""
file_manager.open(tmp_file) do |line|
    content << line
end
puts "Open:\n#{content}"
puts "content encoding is #{content.encoding}"

content = file_manager.read(tmp_file).chomp
puts "Read:\n#{content}"
puts "content encoding is #{content.encoding}"

%x{rm -f #{tmp_file}}
