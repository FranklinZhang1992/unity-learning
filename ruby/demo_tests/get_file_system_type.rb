require 'pathname'

def http?(path)
  return path.match(Regexp.new('^http://\S*$'))
end
def https?(path)
  return path.match(Regexp.new('^https://\S*$'))
end
def iso?(path)
  return path.match(Regexp.new('^\S*.iso$'))
end

def fs_type(path)
  # Work up the path until a directory that exists is found.
  found_dir = nil
  Pathname.new(path).ascend do |dir|
      if File.directory?(dir)
          found_dir = dir
          break
      end
  end

  cmd = "stat -f -c %T \"#{found_dir}\""
  # logDebug {"calling '#{cmd}'"}
  result = %x{#{cmd} 2>&1}
  # logDebug {"'#{cmd}' returned #{result}"}
  unless $? == 0
    puts "'#{cmd}' failed with #{result}"
      return nil
  end
  return "" if result.nil?
  result.strip
end

def prepare_mount_point
  name = "centos"
  mount_point = "/mnt/iso/#{name}-iso"
  return mount_point
end

def mount(full_path)
  params = {}
  result = full_path.match(Regexp.new('^([\S]*)/([\S]*\.iso)$'))
  params[:mount_url] = result[1]
  puts "iso is #{result[2]}"
  mount_point = do_mount(params)
  puts mount_point
end

def do_mount(params={})
  mount_url = params[:mount_url]
  mount_point = params[:mount_point] || prepare_mount_point
  return mount_point
end

def get_remote_type(path)
  params = {}
  if http?(path)
      return "http"
  elsif https?(path)
      return "https"
  else
      fs_type = fs_type(path)
      params[:path] = path
      do_mount(params)
      return fs_type
  end
end

def main(path)
  case get_remote_type(path)
  when "http", "https"
    puts "is http or https"
  when "nfs", "cifs"
    puts "is nfs or cifs"
  else
    puts "others"
  end
end

# main("http://sn.com/tmp/windows.iso")
# main("https://sn.com/tmp/windows.iso")
# main("/tmp/windows.iso")
# main("/home/franklin/temp/windows.iso")

mount("134.111.24.224:/developer/fzhang/my-pool/en_windows_server_2012_r2_x64_dvd_2707946.iso")
