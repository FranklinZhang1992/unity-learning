def test(par1=nil, par2=nil)
  puts "par1 = #{par1}" if !par1.nil?
  puts "par2 = #{par2}" if !par2.nil?
  puts "all are nil" if par1.nil? && par2.nil?
end

test
test("a")
test(nil, "b")
