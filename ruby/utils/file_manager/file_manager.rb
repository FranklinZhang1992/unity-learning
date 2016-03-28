#!/usr/bin/ruby
# encoding: utf-8

$INSTALL = "/home/franklin/workspace/unity-learning/ruby/utils/file_manager"
$:.unshift($INSTALL)

require 'singleton'
require 'rbconfig'
require 'pathname'
require 'base/logging'

def file_manager() FileManagerService.instance end

class FileManagerService
  include Singleton
  attr_accessor :monitor_folder
  MANAGED_FOLDER = "^(\\S*)[【](\\d+)[】]$"
  def my_thread() Thread.current.to_s[/[1-9][0-9a-f]+/] end
  def log_title
    title = 'FileManagerService'
    title = "#{title}:#{my_thread}"
    title
  end
  def fs_type(path)
    found_dir = nil
    Pathname.new(path).ascend do |dir|
      if File.directory?(dir)
        found_dir = dir
        break
      end
    end

    cmd = "stat -f -c %T \"#{found_dir}\""
    logDebug {"calling '#{cmd}'"}
    result = %x{#{cmd} 2>&1}
    logDebug {"'#{cmd}' returned #{result}"}
    unless $? == 0
        logWarning {"'#{cmd}' failed with #{result}"}
        return nil
    end
    return "" if result.nil?
    result.strip
  end
  def scan_folder(folder)
    logNotice {"scanning #{folder}"}
     Dir.foreach(folder) { |x|
      next if  x == "." || x == ".."
      # Only deal with the first level
      if File::directory?(File.join(folder, x))
        file_num = 0
        Dir.foreach(File.join(folder, x)) { |file|
          next if  file == "." || file == ".."
          file_num += 1
        }
        old_name = x.to_s
        result = old_name.match(Regexp.new(MANAGED_FOLDER))
        new_name = nil
        if result
          file_name = result[1]
          origin_num = result[2]
          new_name = "#{file_name}【#{file_num}】"
        else
          new_name = "#{old_name}【#{file_num}】"
        end
        if new_name != old_name
          File.rename(File.join(folder, old_name), File.join(folder, new_name))
          logNotice {"Rename file #{old_name} to #{new_name}"}
        end
      end
     }
  end
end

class Main
  attr_accessor :mgmt_folder

  SAMBA_FOLDER = "^//(\\d{1,3}[.]){3}\\d{1,3}/\\S*$"
  NFS_FOLDER = "^(\\d{1,3}[.]){3}\\d{1,3}[:]/\\S*$"
  LINUX_FOLDER = "^/\\S*$"
  WINDOWS_FOLDER = "^[A-Z]:\\\\S*$"

  def my_thread() Thread.current.to_s[/[1-9][0-9a-f]+/] end
  def log_title
    title = 'Main'
    title = "#{title}:#{my_thread}"
    title
  end
  def validate(type, str)
    return false if str.nil?
    case type
    when "samba"
      return str.match(Regexp.new(SAMBA_FOLDER))
    when "linux"
      return str.match(Regexp.new(LINUX_FOLDER))
    when "windows"
      return str.match(Regexp.new(WINDOWS_FOLDER))
    else
      return false
    end
  end
  def samba_folder?(path)
    return validate("samba", path)
  end
  def linux_folder?(path)
    return validate("samba", path)
  end
  def windows_folder?(path)
    return validate("windows", path)
  end
  def get_os_type
    os_type = nil
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      os_type = "windows"
    when /darwin|mac os/
      os_type = "macosx"
    when /linux/
      os_type = "linux"
    when /solaris|bsd/
      os_type = "unix"
    else
      logWarning { "Unknown os: #{host_os.inspect}" }
    end
    os_type
  end
  def boot
    loop { run }
  end
  def shutdown(singal)
    logNotice {"Received signal #{singal}"}
    clean_mount_point
    logNotice {"File manager will shut down"}
    thread = Thread.current
    thread.exit
  end
  def run
    if self.mgmt_folder.nil?
      puts "Please input the folder which you want to manage:"
      folder = gets.chomp
      prepared_folder = begin
                          prepare_folder(folder)
                        rescue => e
                          logError { "Error during preparing folder => #{e}" }
                          nil
                        end
      if prepared_folder.nil?
        puts "Not a valid folder, please input again!"
        return
      end
      self.mgmt_folder = prepared_folder
      msg = "#{self.mgmt_folder} is now under management!"
      puts msg
      logNotice { msg }
    else
      file_manager.scan_folder(self.mgmt_folder)
    end
    sleep 5
  end
  REMOTE_FILE_SYSTEM = "^//\\d+:\\d+:\\d+:\\d+/\\S*$"
  def get_mount_point() "/mnt/mountpoint" end
  def prepare_mount_point
    dir = get_mount_point
    fs_type = file_manager.fs_type(dir) if File.exist?(dir)
    if fs_type == 'nfs' || fs_type == 'cifs'
      %x{umount -v #{dir}}
    end
    %x{mkdir -p #{dir}}
    return dir
  end
  def clean_mount_point
    dir = get_mount_point
    fs_type = file_manager.fs_type(dir) if File.exist?(dir)
    if fs_type == 'nfs' || fs_type == 'cifs'
      %x{umount -v #{dir}}
      %x{rmdir  #{dir}}
      logNotice {"Successfully cleaned mount point #{dir}"}
    end
  end
  def prepare_folder(folder)
    return nil if folder.nil?
    prepared_folder = nil
    if samba_folder?(folder)
      os_type = get_os_type
      if os_type != "linux"
        raise "Only in Linux, samba type is supported."
      end
      puts "Please input the user name:"
      user_name = gets.chomp
      raise "User name is required" if user_name.nil?
      puts "Please input the password:"
      password = gets.chomp
      raise "Password is required" if password.nil?
      mount_point = prepare_mount_point
      mount_cmd = "mount #{folder} #{mount_point} -o username=#{user_name},password=#{password}"
      %x{#{mount_cmd}}
      fs_type = file_manager.fs_type(mount_point)
      return nil unless fs_type == 'nfs' || fs_type == 'cifs'
      prepared_folder = mount_point
    elsif linux_folder?(folder)
      prepared_folder = folder
    elsif windows_folder?(folder)
      prepared_folder = folder
    end
    prepared_folder
  end

end

begin
  main = Main.new
  trap("INT") { main.shutdown('INT')}
  trap("TERM") { main.shutdown('TERM')}
  main.boot
rescue => e
  logError {"Error occured during running file manager => #{e}"}
end

