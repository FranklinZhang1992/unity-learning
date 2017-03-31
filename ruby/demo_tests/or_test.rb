a = 0
b = 100
c = nil
d = (a || b)
puts d
d = (c || b)
puts d

def var
    $v ||= begin
        puts "call block"
        "test"
    end
end

p var
p var
