def is_valid_mac?(mac)
    pattern = Regexp.new("^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$")
    pattern.match(mac) ? true : false
end

mac1 = "123"
puts "#{mac1} is valid? => #{is_valid_mac?(mac1)}"
mac2 = "00:04:fc:40:c3:01"
puts "#{mac2} is valid? => #{is_valid_mac?(mac2)}"
mac3 = "00:04:FC:40:C3:01"
puts "#{mac3} is valid? => #{is_valid_mac?(mac3)}"
