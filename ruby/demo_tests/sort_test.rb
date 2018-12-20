require 'set'

values = Set.new
values << 3
values << 1
values << 2


current = 2

puts values.sort.find { |val| val > current }

arr = []
arr << "s.3"
arr << "s"
arr << "s.1"
arr << "s.2"
arr.sort!.reverse!

p arr
