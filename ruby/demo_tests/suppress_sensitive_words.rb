def suppress_sensitive_words(str)
  puts "before: #{str}"
  suppressed_str = nil
  pattern = Regexp.new('<[0-9a-z\-_]{0,}passw[o]{0,1}[r]{0,1}d>[\S\s]*?</[0-9a-z\-_]{0,}passw[o]{0,1}[r]{0,1}d>', true)
  pattern2 = Regexp.new('(<[0-9a-z\-_]{0,}passw[o]{0,1}[r]{0,1}d>)[\S\s]*?(</[0-9a-z\-_]{0,}passw[o]{0,1}[r]{0,1}d>)', true)
  # result_array = pattern.scan(str).to_a
  result_array = str.scan(pattern).to_a
  result_array.each do |matched|
    result = matched.match(pattern2)
    befor_str = result[0]
    begin_node = result[1]
    end_node = result[2]
    begin_index = matched.index(begin_node)
    end_index = matched.index(end_node)
    replaced_str = matched[begin_index, begin_index + begin_node.length]
    replaced_str += "******"
    replaced_str += matched[end_index, begin_index + end_node.length]
    str = str.gsub(befor_str, replaced_str)
  end
  puts "after: #{str}"
  puts "======================================="
end


begin
  test_strs = []
  test_strs << "<password>123456</password>"
  test_strs << "<passwd>123456</passwd>"
  test_strs << "<user-password>123456</user-password>"
  test_strs << "<user_password>123456</user_password>"
  test_strs << "<Password>123456</Password>"
  test_strs << "<password>123456</password>"
  # test_strs << "<password><password></password></password>" # ???

  merged_str = ""
  test_strs.each do |str|
    merged_str += str
    # suppress_sensitive_words(str)
  end
  suppress_sensitive_words("<xml>#{merged_str}</xml>")
rescue Exception => e
  raise
end
