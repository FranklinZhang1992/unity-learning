str = "abc"
puts "hello [nil]" unless nil
puts "hello [abc]" unless str
puts "hello [nil][abc]" unless nil || str
puts "hello [nil][nil]" unless nil || nil
