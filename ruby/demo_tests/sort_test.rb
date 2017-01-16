require 'set'

values = Set.new
values << 3
values << 1
values << 2


current = 2

puts values.sort.find { |val| val > current }
