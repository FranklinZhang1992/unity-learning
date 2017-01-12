def load
    arr = ["a", "b", "1", "2", "c"]
    arr.each do |a|
        yield(a)
    end
end

def test
    word = []
    load do |a|
        if a =~ /[a-z]/
            word << a
        end
    end
    p word
end

begin
    test
rescue Exception => e
    raise
end
