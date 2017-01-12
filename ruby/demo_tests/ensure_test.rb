def test
    begin
        puts "normal"
        raise "test error"
    rescue => err
        puts "exception, #{err.class}"
        raise
    ensure
        puts "ensure"
    end
end

test
