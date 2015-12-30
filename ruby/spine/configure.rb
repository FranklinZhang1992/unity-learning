#!/usr/bin/ruby

require 'socket'
require 'yaml'

$HOME_PATH = ENV['HOME']
$ROOT_PATH = "/tmp/spine"
$INSTALL = "#{$HOME_PATH}/workspace/unity-learning/ruby/spine"
$:.unshift($INSTALL)
$SYSCONFIG = "#{$ROOT_PATH}/etc/sysconfig/spine"
link2addr = Hash.new
link2mac = Hash.new
[ :priv0, :ibiz0 ].each do |dev|
	cmd = ""
	output = %x{#{cmd} 2> /dev/null}
	if $?.success?
		output.each_line do |line|
			mac = '' #TODO
			address = '' #TODO
			link2addr[dev] = address
			link2mac[dev] = mac
		end
	end
end

$private_address = "#{link2addr[:priv0]}%priv0" if link2addr[:priv0]
$public_address = "#{link2addr[:ibiz0]}%biz0" if link2addr[:ibiz0]

def dmiconf
    %x{#{$ROOT_PATH}/usr/lib/spine/bin/dmiconfigure}.each_line {|line| puts line}
    sleep 5
end

dmiconf until File.exists? $SYSCONFIG unless File.exists? $SYSCONFIG

def load_sysconfig
	IO.read($SYSCONFIG).each_line do |line|
		key, value = line.strip.split('=')
		next if key.nil?
		case key
		when 'PM_UUID';
			$PM_UUID = value
		end
	end
end

load_sysconfig
if $PM_UUID.nil?
	%x{#{$ROOT_PATH}/usr/lib/spine/bin/dmiconfigure}.each_line { |line|
		puts line
	}
	load_sysconfig
end
raise "Failed to load sysconfig" if $PM_UUID.nil?
$UUID = IO.read("#{$ROOT_PATH}/etc/opt/ft/node-config-uuid").strip

File.open("#{$SYSCONFIG}.new", 'w') do |o|
	o.puts "PM_UUID=#{$PM_UUID}"
	o.puts "UUID=#{$UUID}"
	o.puts "PUBLIC_ADDRESS=#{$public_address}" if $public_address
	o.puts "PRIVATE_ADDRESS=#{$private_address}" if $private_address
end
File.chmod(0644, "#{$SYSCONFIG}.new")
File.rename("#{$SYSCONFIG}.new", $SYSCONFIG)

puts "Set node hostname property to : #{Socket.gethostname}"
File.open("#{$ROOT_PATH}/etc/opt/ft/spine/nodes/#{$UUID}/hostname", 'w') { |o| YAML.dump(Socket.gethostname,o) }
File.open("#{$ROOT_PATH}/etc/opt/ft/spine/nodes/#{$UUID}/uuid",'w') { |o| YAML.dump($UUID,o) }
File.open("#{$ROOT_PATH}/etc/opt/ft/spine/nodes/#{$UUID}/pm_uuid",'w') { |o| YAML.dump($PM_UUID,o) }
File.open("#{$ROOT_PATH}/etc/opt/ft/spine/nodes/#{$UUID}/class",'w') { |o| o.print 'SuperNova::NodeConfig' }
File.open("#{$ROOT_PATH}/etc/opt/ft/spine/nodes/#{$UUID}/public_v6", 'w') { |o| YAML.dump($public_address,o) }
File.open("#{$ROOT_PATH}/etc/opt/ft/spine/nodes/#{$UUID}/private_v6",'w') { |o| YAML.dump($private_address,o) }

File.open("#{$ROOT_PATH}/etc/opt/ft/spine/nodes/#{$UUID}/boot_count",'w') { |o| YAML.dump(0, o) }

File.open("#{$ROOT_PATH}/etc/opt/ft/spine/nodes/#{$UUID}/priv0_mac_addr",'w') { |o| YAML.dump(link2mac[:priv0],o) } unless link2mac.empty?
puts "Local priv0 MAC is #{link2mac[:priv0]}"

puts 'Successfully finished running spine configure!'
Kernel.exit true
