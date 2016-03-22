require 'timeout'

begin
  timeout(2) { sleep 5}
rescue Timeout::Error => err
  puts "err = #{err}"
rescue Exception => e
  puts "#{e.class}"
  puts "#{e}"
end
