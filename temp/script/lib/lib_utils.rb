require 'pathname'

def get_pool_base
    "/developer"
end

def exec_cmd(cmd, verbose=true)
    puts "exec: #{cmd}"
    IO.popen(cmd) { |io|
      while line = io.gets
        puts line.chomp if verbose
      end
    }
    $?.success?
end

def build_server
    IO.read("./build_server").strip
rescue
    nil
end
