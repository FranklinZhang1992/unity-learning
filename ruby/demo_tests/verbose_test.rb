$verbose = false

def method1
    raise "error occur"
end

def method2
    method1
end

def method3
    method2
end

begin
    param = ARGV[0].nil? ? nil : ARGV[0].chomp
    if param == "v"
        $verbose = true
    end
    # puts "verbose = #{$verbose}"
    method3
rescue Exception => err
    if $verbose
        puts "#{err} (#{err.class})\n#{err.backtrace.join("\n\tfrom ")}"
    else
        puts "#{err}"
    end
end
