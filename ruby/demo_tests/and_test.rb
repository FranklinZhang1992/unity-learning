def check1
  return "1"
end
def check2
  return "2"
end
def check3
  return nil
end

if check1.nil? and check2.nil? and check3.nil?
  puts "wrong"
else
  puts "yes"
end
