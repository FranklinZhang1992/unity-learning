path1 = "/watch"
path2 = "/network"

dispatch = path1.split('/')
puts "====#{dispatch[dispatch.length - 1]}====="
case dispatch
when "watch"
    puts "watch"
when "network"
    puts "network"
else
    puts "ALL"
end