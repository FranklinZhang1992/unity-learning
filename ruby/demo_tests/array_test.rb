arr = nil
begin
    puts "arr = nil, empty?: #{arr.empty?}"
rescue => err
    puts "arr = nil, empty?: #{err}"
end
arr = []
puts "arr = [], empty?: #{arr.empty?}"
str = nil
begin
    arr = str.split(' ')
    p arr
rescue => err
    puts "error: #{err}"
end
str = ""
arr = str.split(' ')
p arr
str = "0 1 2"
arr = str.split(' ')
p arr
