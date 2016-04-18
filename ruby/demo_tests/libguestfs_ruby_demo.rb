require 'guestfs'

begin
  puts "Please input the path:"
  path = gets.chomp
  raise "Media not found" unless File.exist?(path)
  g = Guestfs::Guestfs.new()
  g.add_drive_opts(path,
                  :readonly => 1, :format => "raw")
  g.launch()
  roots = g.inspect_os()
  if roots.length == 0
    puts "inspect_vm: no operating systems found"
    exit 1
  end
  for root in roots do
    printf("Root device: %s\n", root)

    # Print basic information about the operating system.
    printf("  Product name: %s\n", g.inspect_get_product_name(root))
    printf("  Version:      %d.%d\n",
            g.inspect_get_major_version(root),
            g.inspect_get_minor_version(root))
    printf("  Type:         %s\n", g.inspect_get_type(root))
    printf("  Distro:       %s\n", g.inspect_get_distro(root))

    # Mount up the disks, like guestfish -i.
    #
    # Sort keys by length, shortest first, so that we end up
    # mounting the filesystems in the correct order.
    mps = g.inspect_get_mountpoints(root)
    mps = mps.sort {|a,b| a[0].length <=> b[0].length}
    for mp in mps do
      begin
         g.mount_ro(mp[1], mp[0])
      rescue Guestfs::Error => msg
        printf("%s (ignored)\n", msg)
      end
    end

    # If /etc/issue.net file exists, print up to 3 lines.
    filename = "/etc/issue.net"
    if g.is_file filename then
      printf("--- %s ---\n", filename)
      lines = g.head_n(3, filename)
      for line in lines do
         puts line
      end
    end
    # Unmount everything.
    g.umount_all()
  end
rescue Exception => e
  puts "error occur => #{e}"
end
