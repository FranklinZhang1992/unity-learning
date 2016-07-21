def suppress_sensitive_info(request_body)
  data = "#{request_body}"
  puts "before: #{data}"
  begin_index = data.index('<password>')
  end_index = data.index('</password>')
  if begin_index.nil? || end_index.nil?
    filtered_data = data
  else
    filtered_data = data[0, begin_index + 10]
    filtered_data += "******"
    filtered_data += data[end_index, data.length - end_index]
  end
  puts "after: #{filtered_data}"
end

suppress_sensitive_info("<?xml version='1.0'?><domain id=\"1\"><password>password</password></domain>")
suppress_sensitive_info("<?xml version='1.0'?><domain id=\"1\"><name>admin</name></domain>")
