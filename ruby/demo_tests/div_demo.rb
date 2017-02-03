start = 0
stop = 5
step = 1
allowed_range = (start..stop)
len = stop - start
num = len.div(step)
puts "num = #{num}"
result = (0..num).map { |i| puts "i = #{i}"; start + step * i }
p result

puts "===================="
puts 3.div(2)
puts 2.div(3)
puts 2.div(1)

puts "===================="
puts 3 / 2
puts 2 / 3
puts 2 / 1
