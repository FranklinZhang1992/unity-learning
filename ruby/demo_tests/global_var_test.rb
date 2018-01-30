TMP_FILE_PATH = "/tmp/temp.tmp.#{Time.now.to_i}"
$IS_FILE_EXIST = File.exist?(TMP_FILE_PATH)

puts "file exist? #{$IS_FILE_EXIST}"
puts "create temp file"
%x{touch #{TMP_FILE_PATH}}
puts "file exist? #{$IS_FILE_EXIST}"
%x{rm -f #{TMP_FILE_PATH}}
