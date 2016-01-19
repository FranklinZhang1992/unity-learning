UUID = IO.read('/proc/sys/kernel/random/uuid').strip

content = begin IO.read('/abc').strip rescue "no" end

puts UUID
puts content
