#!/usr/bin/ruby

require 'sdbm'
require 'yaml'
require 'socket'

$ROOT_PATH = "/tmp/spine"
$SYSCONFIG_PATH = "#{$ROOT_PATH}/etc/sysconfig"
$config = "#{$ROOT_PATH}/etc/opt/ft/spine"

module SMBIOS
    Handler = Hash.new
    class Handle
        def initialize(id, lines)
            @id = id
            @attributes = Hash.new
            lines.each do |line|
                next unless line.match(/\s*(\S[^:]+): (\S.*)/)
                @attributes[$1] = $2
            end
        end
        def name() self.class.to_s.downcase end
        def directory(base) "#{base}/#{self.name}" end
        def mkdir(base)
            dir = directory(base)
            Dir.mkdir(dir) unless File.directory? dir
        end
        def configure(base)
            self.mkdir(base)
            @attributes.each do |key,value|
                filename = "#{self.directory(base)}/#{key.downcase}"
                File.open(filename, 'w') {|o| o.puts value}
                File.chmod(0644, filename)
            end
        end
    end
    class System < Handle
        def name() 'system' end
        def uuid() @attributes['UUID'].downcase end
    end
    Handler[1] = System
    class BaseBoard < Handle
        def name() 'mainboard' end
    end
    Handler[2] = BaseBoard
    class Chassis < Handle
        def name() 'chassis' end
    end
    Handler[3] = Chassis
    class Processor < Handle
        def name() 'socket' end
        def configure(base)
            # subdir = "#{base}/#{@id}"
            # Dir.mkdir(subdir) unless File.directory? subdir
            # super(subdir)
        end
    end
    Handler[4] = Processor
    class MemoryDevice < Handle
        def name() 'memory' end
        def configure(base)
            # subdir = "#{base}/#{@id}"
            # Dir.mkdir(subdir) unless File.directory? subdir
            # super(subdir)
        end
    end
    Handler[17] = MemoryDevice

    class Manager
        def initialize
            @info = Array.new
            handles = %x{dmidecode 2>&1}.split(/^Handle /)
            handles.shift
            handles.each do |handle|
                lines = handle.split("\n")
                lines.shift.match(/(0x\w+), DMI type (\d+),.*/)
                handle_id = $1
                type = $2.to_i
                # puts "DMI handle_id #{handle_id} type #{type}"
                handler = Handler[type]
                if handler.nil?
                    # puts "no handler for type #{type}"
                    next
                end
                @info << handler.new(handle_id, lines)
            end
        end
        def node_uuid() IO.read("#{$ROOT_PATH}/etc/opt/ft/node-config-uuid") end
        def system() @info.detect {|e| e.class.to_s == 'SMBIOS::System'} end
        def chassis() @info.detect {|e| e.class.to_s == 'SMBIOS::Chassis'} end
        def mainboard() @info.detect {|e| e.class.to_s == 'SMBIOS::BaseBoard'} end
        def directory(subdir='')
            "#{$config}/nodes/#{node_uuid}" + (subdir.nil? ? '' : "/#{subdir}")
        end
        def open(filename)
        end
        def configure
            Dir.mkdir self.directory unless File.directory? self.directory
            localnode_symlink = "#{$ROOT_PATH}/var/opt/ft/spine/localnode"
            File.symlink(self.directory, localnode_symlink) unless File.exists?(localnode_symlink)
            Dir.mkdir self.directory('devices') unless File.directory? self.directory('devices')
            File.chmod(0755, self.directory)
            @info.each do |handle|
                handle.configure( self.directory('devices') )
            end
        end
    end
end

x = SMBIOS::Manager.new

if x.system.uuid.nil?
    raise "ERROR -- couldn't find the system UUID"
end
puts "System UUID: #{x.system.uuid}"
x.configure

File.open("#{$SYSCONFIG_PATH}/spine.new",'w') do |o|
    o.puts "PM_UUID=#{x.system.uuid}"
end
File.chmod(0644, "#{$SYSCONFIG_PATH}/spine.new")
File.rename("#{$SYSCONFIG_PATH}/spine.new", "#{$SYSCONFIG_PATH}/spine")

Kernel.exit true
