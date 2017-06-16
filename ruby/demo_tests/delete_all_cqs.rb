require 'json'

def send_influxql_request(statement)
    %x{curl -i -XPOST http://localhost:8086/query --data-urlencode "q=#{statement}"}
end

def send_show_all_cqs_request
    send_influxql_request("SHOW CONTINUOUS QUERIES")
end

def send_delete_cq_request(db_name, cq_name)
    statement = "DROP CONTINUOUS QUERY \"#{cq_name}\" ON \"#{db_name}\""
    send_influxql_request(statement)
end

def filter(orig_str)
    orig_str[orig_str.index("{\"results\""), orig_str.length - orig_str.index("{\"results\"")]
end

def delete
    r = send_show_all_cqs_request
    r = filter(r)
    obj = JSON.parse(r)
    series_arr = obj["results"][0]["series"]
    series_arr.each do |series|
        db_name = series["name"]
        cq_arr = series["values"].nil? ? [] : series["values"]
        cq_arr.each do |cq|
            cq_name = cq[0]
            send_delete_cq_request(db_name, cq_name)
        end
    end
end

begin
    delete
rescue Exception => e
    raise
end
