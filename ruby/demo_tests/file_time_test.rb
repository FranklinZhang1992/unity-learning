file = "test_file"
%x{touch #{file}}
puts "File created at #{Time.now}"
sleep 2
%x{echo "xxxx" > #{file}}
puts "File modified at #{Time.now}"
sleep 2
t1 = File::ctime(file)
t2 = File::mtime(file)
t3 = File::atime(file)

puts "file created at #{t1}, modified at #{t2}, accessed at #{t3}"

%x{rm -f #{file}}
