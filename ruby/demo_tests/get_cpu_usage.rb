require 'json'

def send_influxql_request(statement)
    %x{curl -i -XPOST http://localhost:8086/query?db="collectd_node0" --data-urlencode "q=#{statement}"}
end

def filter(orig_str)
    orig_str[orig_str.index("{\"results\""), orig_str.length - orig_str.index("{\"results\"")]
end

def get_total_cpu_usage(domainId)
    cpu_count = 5
    statement = "SELECT derivative(MEAN(\"value\")) / (#{cpu_count} * 20 * 1000000000) AS \"value\" FROM \"virt_value\" WHERE \"type\" = 'virt_cpu_total' AND \"time\" >= now() - 20s AND \"time\" < now() GROUP BY \"host\",\"instance\",\"type_instance\",time(20s)"
    r = send_influxql_request(statement)
    r = filter(r)
    obj = JSON.parse(r)
    obj["results"][0]["series"][0]
    usage = obj["results"][0]["series"][0]["values"][0][1].to_f * 100
    "#{usage}%"
end

def get_total_cpu_usage_from_per_cpu_usage(domainId)
    statement = "SELECT DERIVATIVE(MEAN(\"value\")) / (20 * 1000000000) AS \"value\" FROM \"virt_value\" WHERE \"type\" = 'virt_vcpu' AND \"time\" >= now() - 20s AND \"time\" < now() GROUP BY \"host\",\"instance\",\"type_instance\",time(20s)"
    r = send_influxql_request(statement)
    r = filter(r)
    obj = JSON.parse(r)
    sub_usages = []
    obj["results"][0]["series"].each do |series|
        sub_usages << series["values"][0][1].to_f * 100
    end
    usage = 0
    count = 0
    sub_usages.each do |sub_usage|
        count += 1
        usage += sub_usage
    end
    usage_percent = "#{usage / count}%"
    usage_percent
end

begin
    loop do
        domainId = nil
        usage1 = get_total_cpu_usage(domainId)
        usage2 = get_total_cpu_usage_from_per_cpu_usage(domainId)
        puts "#{Time.now} #{usage1} #{usage2}"
        sleep 10
    end
rescue Exception => e
    raise
end
