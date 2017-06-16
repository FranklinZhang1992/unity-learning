#!/usr/bin/ruby

class Demo
    def print
        puts "print"
        sleep 1
    end
    def get_influxd_pid
        pid = %x{ps -ef | grep /usr/bin/influxd | grep -v grep | awk '{print $2}'}
        puts "pid = #{pid}"
        pid.to_i
    end
end

demo = Demo.new
demo.print
p demo.get_influxd_pid
demo.print
