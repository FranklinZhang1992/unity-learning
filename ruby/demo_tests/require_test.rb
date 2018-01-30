$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sub_test'

$GLOBAL_VAR = "ABC"

demo = Demo.new
puts demo.var
