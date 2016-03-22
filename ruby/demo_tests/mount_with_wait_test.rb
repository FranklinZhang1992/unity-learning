require 'timeout'

def mount_rfs
  begin
    timeout(2) {%x{mount -rv //134.111.1.228/Users/TEST/p2v/folder_test /mnt/test/test1 -o username=TEST,password=abc123_}}
    # io = IO.popen("mount -rv //134.111.1.228/Users/TEST/p2v/folder_test /mnt/test/test1 -o username=TEST,password=abc123_") { |f|
    #   puts f.gets
    # }
    # wait
  rescue Timeout::Error => err
    puts "err = #{err}"
  rescue Exception => e
    puts "Exception => #{e}"
  end
end

def wait
  cmd = "stat -f -c %T \"/mnt/test/test1\""
  result = nil
  ask_count = 0
  while result != "cifs" && result != "nfs"
    if ask_count > 2
      break
    end
    result = %x{#{cmd} 2>&1}
    ask_count += 1
    puts "ask count = #{ask_count}"
    sleep 2
  end
  result = %x{#{cmd} 2>&1}
  if result == "cifs"
    puts "mount success, type is cifs"
  elsif result == "nfs"
    puts "mount success, type is nfs"
  else
    puts "mount failed"
  end
end

mount_rfs
