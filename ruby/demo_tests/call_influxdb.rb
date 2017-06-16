def send_influxql_request(statement)
    %x{curl -i -XPOST http://localhost:8086/query?epoch=ms --data-urlencode "db=\"collectd_node0\" --data-urlencode "q=#{statement}"}
end

def filter(orig_str)
    orig_str[orig_str.index("{\"results\""), orig_str.length - orig_str.index("{\"results\"")]
end

def call(statement)
    r = send_influxql_request(statement)
    # r = filter(r)
    puts r
end

begin
    # statement = "select * from \"collectd_node0\".\"four_hours\".\"virt_vcpu_usage_4h\" WHERE \"instance\" = '68efb9e1-4eab-4a2c-a343-bcfea96910b1' GROUP BY \"type_instance\" ORDER BY time DESC LIMIT 1"
    # statement = "SELECT * FROM \"collectd_node0\".\"four_hours\".\"virt_vcpu_usage_4h\" ORDER BY time DESC LIMIT 4"
    statement = "SELECT MEAN(\"value\") AS \"value\" FROM \"one_hour\".\"memory_usage\" WHERE \"time\" >= now() - 1h AND \"time\" <= now() - 10s GROUP BY \"host\",time(10s) fill(0) ORDER BY time DESC LIMIT 1"
    call(statement)
rescue Exception => e
    raise
end
