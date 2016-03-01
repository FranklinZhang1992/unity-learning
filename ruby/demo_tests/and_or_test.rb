def get_regexp
  return Regexp.new('^[a-z]$')
end

$MAX_LENGTH = 1
$params = {}
$params["value"] = "value"

def test_or(test_str, branch)
  case branch
  when 1
    puts "#{test_str} => #{test_str.match(get_regexp)}"
    test_str.match(get_regexp) or puts "exception"
  when 2
    puts "#{test_str} => #{test_str.size > $MAX_LENGTH}"
    test_str.size > $MAX_LENGTH or puts "exception"
  when 3
    puts "#{test_str} => #{$params["#{test_str}"]}"
    $params["#{test_str}"] or puts "exception"
  end
end

def test_and(test_str, branch)
  case branch
  when 1
    puts "#{test_str} => #{test_str.match(get_regexp)}"
    test_str.match(get_regexp) and puts "exception"
  when 2
    puts "#{test_str} => #{test_str.size > $MAX_LENGTH}"
    test_str.size > $MAX_LENGTH and puts "exception"
  when 3
    puts "#{test_str} => #{$params["#{test_str}"]}"
    $params["#{test_str}"] and puts "exception"
  end
end

test_or("value", 3)
test_or("a", 3)
test_and("value", 3)
test_and("a", 3)
