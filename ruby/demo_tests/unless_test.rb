# str = "abc"
# puts "hello [nil]" unless nil
# puts "hello [abc]" unless str
# puts "hello [nil][abc]" unless nil || str
# puts "hello [nil][nil]" unless nil || nil

def conditionA
    puts "conditionA"
    false
end

def condifitonB
    puts "condifitonB"
    true
end

puts "conditionA && condifitonB = #{conditionA && condifitonB}"

unless conditionA && condifitonB
    puts "unless"
end
