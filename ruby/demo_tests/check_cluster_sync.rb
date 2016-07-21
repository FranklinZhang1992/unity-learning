#!/usr/bin/ruby

class Main
  def run(num)
    for i in 0 .. num - 1 do
      vm_name = "MyVM#{i}"
      xml_pool = "/var/run/ft/domaincontroller"
      %x{cat #{xml_pool}/#{vm_name}.xml | grep hdb 2>&1}
      result_node0 = $?.success?
      %x{ssh peer cat #{xml_pool}/#{vm_name}.xml | grep hdb 2>&1}
      result_node1 = $?.success?
      if result_node0 && result_node1
        puts "#{vm_name} is good"
      else
        puts "#{vm_name} is not in sync state"
      end
    end
  end
end

begin
  puts "input total vm number:"
  num = gets.chomp.to_i
  main = Main.new
  main.run(num)
rescue Exception => e
  raise
end
