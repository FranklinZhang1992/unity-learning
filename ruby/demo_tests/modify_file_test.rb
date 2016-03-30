def modify_file
  begin
    content = []
    io = File.open("/home/franklin/workspace/temp/test")
    io.each_line do |line|
      line.chomp!
      if line == "RELEASE:=R$(MAJOR_REV).$(MINOR_REV).$(MAINT_REV)"
        content << "UNITY_PACKAGER := jsong\n"
      end
      content << "#{line}\n"
    end
    io.close
    io = File.open("/home/franklin/workspace/temp/test", 'w')
    io.puts content
    io.close
  rescue Exception => e
    puts "Failed to modify file => #{e}"
  end
end

modify_file
