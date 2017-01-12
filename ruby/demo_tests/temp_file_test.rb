require 'tempfile'
require 'fileutils'

current_floder = %x{pwd}
# puts current_floder

arr = ["* * * * * echo \"hello world\" >> /tmp/temp.out", "* * * * * echo \"hello world2\" >> /tmp/temp.out"]
result = nil
# Tempfile.open('foo', '/developer') do |f|
#    arr.each do |a|
#        f.puts a
#    end
#    path = f.path
#    puts "path = #{path}"
#    result = %x{cat #{path}}
# end

# puts "result: #{result}"

content1 = "line1\nline2\nline3\n"
content2 = "content2"
content3 = "Hello World"

temp_file = Tempfile.open('foo', '/developer')
begin
    # arr.each do |a|
    #     temp_file.puts a
    # end
    temp_file.puts content1
    temp_file.puts content2
    temp_file.puts content3
    temp_file.flush
    path = temp_file.path
    puts IO.read(path)
    FileUtils.cp(path, '/developer/test_file')
rescue Exception => e
    puts "#{e}"
ensure
    temp_file.close!
end
