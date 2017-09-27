require 'tempfile'
require 'pathname'

def cook_line(raw_line)
    return nil if raw_line.nil?
    cooked_line = raw_line.lstrip.rstrip
    return nil if cooked_line.empty?
    cooked_line
end

class FileRWManager

    DEFAULT_ENCODING = "UTF-8"

    def initialize(encoding=nil)
        if encoding.nil?
            @encoding = DEFAULT_ENCODING
        else
            Encoding.find(encoding)
            @encoding = encoding
        end
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
            cooked_line = cook_line(line)
            content << cooked_line << "\n"
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

file_manager = FileRWManager.new
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
