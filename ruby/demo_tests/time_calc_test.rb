begin
  start_time = Time.now
  sleep 5
  end_time = Time.now
  interval = end_time - start_time
  puts interval
rescue Exception => e
  
end