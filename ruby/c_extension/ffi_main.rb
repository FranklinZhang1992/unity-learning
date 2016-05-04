require 'ffi'
require './demo'

c = Demo.calculate_something(42, 98.6)
puts "calculate_something: #{c}"
