require 'set'

def main
    s1 = Set.new
    s2 = Set.new

    s1 << "a"
    s1 << "b"
    s1 << "c"

    s2 << "c"
    s2 << "b"
    s2 << "a"
    s2 << "d"

    if s1 == s2
        puts "yes"
    else
        puts "no"
    end
end

main
