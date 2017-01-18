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

arr = ["1", "a", "c", 2, "a"]
p arr
p arr.uniq

arr1 = ["1", "a", "3"].sort
arr2 = ["3", "1", "a"].sort

eql = arr1.eql?(arr2)
puts "arr1 == arr2 ? => #{eql}"
