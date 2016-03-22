# Exec command and get the return value
require 'fileutils'
def mount
  puts File.exist?("/mnt/mountpoint")
  FileUtils.mkdir_p("/mnt/point")
  %x{umount -v /mnt/point}
  mount_cmd = "mount //192.168.0.104/shared /mnt/point -o username=franklin,password=abc123"
  %x{#{mount_cmd}}
end

def exec
  puts Time.now
  io = IO.popen("sleep 5")
  io.close
  puts Time.now
end

# mount
exec
