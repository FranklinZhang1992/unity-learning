connection_listeners = []

begin
    i = 0;
    listener_result = lambda { |result|
        if result.kind_of?(Exception)
            puts "call result"
            cb.call(result)
        else
            i += 1
            if i == @connection_listeners.length
                puts "call true"
                cb.call(true)
            else
                puts "another call"
                connection_listeners[i].call(listener_result)
            end
        end
    }
    connection_listeners[0].call(listener_result)
rescue => ex
    @channel.close unless @channel.nil?
    raise ex
end