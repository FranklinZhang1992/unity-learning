def process_start(cmd)
    pid = spawn(cmd)
    # wait_thread = Process.detach(pid)
    wait_thread = 1
end


def execute_thread(cmd)
    begin
        wait_thread = process_start(cmd)
        pid = wait_thread.pid
        puts "pid is #{pid}"
        cmd1 = "echo \"666\" >> /tmp/temp.out;"
        spawn(cmd1)
    rescue Exception => e
        puts e
    end
end

def background_execute
    cmd = "echo \"abc\" >> /tmp/temp.out; sleep 2; echo \"123\" >> /tmp/temp.out; sleep 2; echo \"456\" >> /tmp/temp.out;"
    thread = Thread.new{execute_thread(cmd)}
    Thread.kill(thread)
end

background_execute
