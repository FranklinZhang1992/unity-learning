def test_method
    begin
        puts "test_method"
        v1 = "v1"
        return
    rescue => err
        puts "rescue #{v1}"
    ensure
        puts "ensure #{v1}"
    end

end

test_method
