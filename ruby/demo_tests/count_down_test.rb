class CountMachine
  def initialize
    @time_point1 = nil
    @time_point2 = nil
    @remaining_time = 0
    @percent = 0
  end

  def percent=(percent)
    @percent = percent
  end
  def percent
    @percent
  end
  def remaining_time
    @remaining_time
  end
  def send_signal(signal)
    case signal
    when "start"
      @time_point1 = Time.now
      @time_point2 = Time.now
      @percent = 0
    when "inprogress"
      @time_point2 = Time.now
      @remaining_time = (((@time_point2 - @time_point1) / @percent) * (100 - @percent)).to_i
    end
  end
end

counter = CountMachine.new
counter.send_signal("start")
loop {
  sleep 5
  counter.percent += 20
  counter.send_signal("inprogress")
  puts "remaining time is #{counter.remaining_time}s"
  if counter.percent == 100
    break
  end
}
