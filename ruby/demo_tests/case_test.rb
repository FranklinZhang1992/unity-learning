def test_case(state)
    case state
    when "a"
        puts "one"
    when "b"
        puts "two"
    when "c"
        puts "three"
    when "d"
        puts "four"
    when "e"
        puts "five"
    end
end

test_case("a")
test_case("b")
test_case("d")
test_case("e")
