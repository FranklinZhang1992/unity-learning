def test(count)
  puts "testing #{count}"
  if count == 5
    return false
  else
    return true
  end
end

begin
  count = 0
  loop {
    count += 1
    result = test(count)
    break unless result
    sleep 2
  }
rescue Exception => e
  puts "Exception occured => #{e}"
  raise
end
