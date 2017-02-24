t1 = Time.now
r1 = %x{ifconfig}
sleep (5)
t2 = Time.now
r2 = %x{ifconfig}
puts "#{t1} =>\n#{r1}"
puts "#{t2} =>\n#{r2}"
