TEST_FILE = "/root/test.tmp"
%x{echo aa > #{TEST_FILE}}
stat1 = File.stat(TEST_FILE)
%x{echo bb > #{TEST_FILE}}
stat2 = File.stat(TEST_FILE)

if stat1 == stat2
    puts "yes"
else
    puts "no"
end
