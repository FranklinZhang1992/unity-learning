#!/usr/bin/ruby

require 'guestfs'

def libguestfs_detect_os(path)
  if !File.exist?(path)
    raise "File does not exist"
  end
  gfs = Guestfs::Guestfs.new()
  gfs.add_drive_opts(path, :readonly => 1)
  gfs.launch
  system = gfs.inspect_os.first
  ostype = gfs.inspect_get_type(system)
  osdistro = gfs.inspect_get_distro(system)
  osproduct = gfs.inspect_get_product_name(system)
  gfs.close
  puts "ostype => #{ostype}, osdistro => #{osdistro}, osproduct => #{osproduct}"
end

begin
  path = ARGV[0].chomp
  libguestfs_detect_os(path)
rescue Exception => e
  raise
end
