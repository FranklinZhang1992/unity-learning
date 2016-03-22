$count = 0
$lock = Mutex.new
def lock_method
  # $lock.synchronize do
    puts "[1] current thread is #{Thread.current}"
    sleep 1
    $count += 1
    puts "[1] [#{Time.now}] current count is #{$count}"
  # end
end

def print_thread
  $lock.synchronize do
    puts "[0] current thread is #{Thread.current}"
    sleep 1
    $count += 1
    puts "[0] [#{Time.now}] current count is #{$count}"
    lock_method
  end
end

start_time = Time.now
puts "#{start_time}"
thread1 = Thread.new {print_thread}
thread2 = Thread.new {print_thread}
thread3 = Thread.new {print_thread}
thread4 = Thread.new {print_thread}

sleep 5

puts "count = #{$count}"
