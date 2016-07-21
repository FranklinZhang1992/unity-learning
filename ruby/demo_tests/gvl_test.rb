require "guestfs"
require 'rexml/document'

include REXML
class Main
  def initialize
    @libguestfs_lock = Mutex.new
  end
  def libguestfs_detect_os(device)
    if !@libguestfs_lock.try_lock
      puts "libguestfs_detect_os: OS detection already in progress..."
      return
    end
    puts "libguestfs_detect_os start@#{Time.now}"
    gfs = Guestfs::Guestfs.new()
    gfs.add_drive_opts(device, :readonly => 1)
    gfs.launch
    system = gfs.inspect_os.first
    ostype = gfs.inspect_get_type(system)
    osdistro = gfs.inspect_get_distro(system)
    osproduct = gfs.inspect_get_product_name(system)
    gfs.close
    puts "ostype = #{ostype}, osdistro = #{osdistro}, osproduct = #{osproduct}"
    puts "libguestfs_detect_os end@#{Time.now}"
    @libguestfs_lock.unlock
  end
  def inspect_os(device)
    puts "inspect_os start@#{Time.now}"
    ostype = nil
    osdistro = nil
    osproduct = nil
    result = %x{virt-inspector -a #{device}}
    if $?.success?
      operatingsystems = begin Document.new(result).root rescue nil end
      unless operatingsystems.nil?
        operatingsystems.elements.each do |operatingsystem|
          ostype = begin operatingsystem.elements['name'].text rescue nil end
          osdistro = operatingsystem.elements['distro'].text
          osproduct = operatingsystem.elements['product_name'].text
          break
        end
      end
    else
      raise "failed to execute command #{virt-inspector} for #{storage.device}"
    end
    puts "ostype => #{ostype}, osdistro => #{osdistro}, osproduct => #{osproduct}"
    puts "inspect_os end@#{Time.now}"
  end
  def run
    @detect_os_thread = Thread.new { libguestfs_detect_os("/mnt/everrun/win7_pro_boot_0619f437-4ac1-4ac7-ba7a-2a27b37bb3e9_node0/win7_pro_boot_0619f437-4ac1-4ac7-ba7a-2a27b37bb3e9_aad9e336-109a-49eb-90c8-68bbf2c4170c") }
    # @inspect_os_thread = Thread.new { inspect_os("/mnt/everrun/win7_pro_boot_0619f437-4ac1-4ac7-ba7a-2a27b37bb3e9_node0/win7_pro_boot_0619f437-4ac1-4ac7-ba7a-2a27b37bb3e9_aad9e336-109a-49eb-90c8-68bbf2c4170c") }
    @thread1 = Thread.new { puts "thread1 start@#{Time.now}"; loop { puts "thread1"; sleep 1 } }
    @thread2 = Thread.new { puts "thread2 start@#{Time.now}"; loop { puts "thread2"; sleep 2 } }
    
    # @inspect_os_thread.join
    @thread1.join
    @thread2.join
    @detect_os_thread.join
  end
end

begin
  main = Main.new
  main.run
rescue Exception => e
  raise
end

