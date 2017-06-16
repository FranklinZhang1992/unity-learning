def send_influxql_request(statement)
    %x{curl -i -XPOST http://localhost:8086/query --data-urlencode "q=#{statement}"}
end

def delete_db
    ["collectd_node0", "collectd_node1"].each do |db_name|
        statement = "DROP DATABASE \"#{db_name}\""
        send_influxql_request(statement)
    end
end

def stop_collectd_service
    %x{systemctl stop collectd}
    %x{ssh root@peer systemctl stop collectd}
end

def stop_influxd_service
    %x{systemctl stop influxd}
end

begin
    stop_collectd_service
    delete_db
    stop_influxd_service
rescue Exception => e
    raise
end
