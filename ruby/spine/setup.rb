#!/usr/bin/ruby

$HOME_PATH = ENV['HOME']
$ROOT_PATH = "/tmp/spine"
$INSTALL = "#{$HOME_PATH}/workspace/unity-learning/ruby/spine"
$:.unshift($INSTALL)

require 'supernova/spine'
require 'supernova/sysconfig'

class SetupTimeout < Exception
end

class File
    def File.write(name, string, seek = 0)
        File.open(name, 'w') do |fh|
            fh.seek(seek)
            fh.write(string)
        end
    end
    def File.append(name, string, seek = 0)
        File.open(name, 'a') do |fh|
            fh.seek(seek)
            fh.write(string)
        end
    end
end

module Template
    def fill_in(template, hash)
        hash.each { |k, v| template.gsub!(k, v)}
        return template
    end
end

module Install
    def install?
        return File.exists?(install)
    end
    def install
        return "#{$ROOT_PATH}/etc/opt/ft/installing"
    end
    def recover?
        return File.exists?(recover)
    end
    def recover
        return "#{$ROOT_PATH}/etc/opt/ft/recovering"
    end
    def peerimage?
        return File.exists?(peerimage)
    end
    def peerimage
        return "#{$ROOT_PATH}/etc/opt/ft/peerimaging"
    end
end
include Install

def cleanup
    puts "Cleaning up installation files ..."
    File.unlink(install) if install?
    File.unlink(recover) if recover?
    File.unlink(peerimage) if peerimage?
    begin
        File.unlink(SuperNova::SysConfig::FILENAME)
    rescue Exception => e
        puts "errors occur during unlink #{SuperNova::SysConfig::FILENAME} => #{e}"
    end
end

def wait_on_local_spine
    local_spine_ready = false
    until local_spine_ready
        begin
            timeout(1200, SetupTimeout) {
                wait("Waiting for local Spine to become ready ...") {$local.ready?}
                local_spine_ready = true
            }
        rescue SetupTimeout => e
            puts "errors occur during waiting on local spine Exception => e"
            sleep 10
            %x{pkill spine}
        end
    end
    return true
end

def peer_ipv6_addrs
    addrs = Array.new
    count = 0
    loop do
        if count == 20
            puts "Try resetting priv0, may be a problem with link auto-negotiation. see case 4840..."
            %x{ip link set eth0 down}
            %x{ip link set eth0 up}
            sleep 10
            count = 0
        end
        %x{ping6 -c 1 -q -I eth0 ff02::1}
        puts "Waiting for the peer to become alive ..."
        %x{/sbin/pi -6 neigh ls dev eth0 to fe80::/10}.each_line do |line|
            addrs << line.strip.split.shift
        end
        break unless address.empty
        sleep 6
        count += 1
    end
end

def peer_ipv6_addr
    return $peer_ipv6_addr if $peer_ipv6_addr
    init_peer_spine
    return $peer_ipv6_addr
end

def init_peer_spine
    return $peer if $peer
    loop do
        peers = Hash.new
        peer_ipv6_addrs.each do |ipv6_addr|
            peers[ipv6_addr] = SuperNova::Spine.new("#{ipv6_addr}%eth0", 8999)
        end

        begin
            timeout(240, SetupTimeout) {
                wait("Waiting for peer Spine to become ready ...") do
                    ready = nil
                    peers.each_key do |ipv6_addr|
                        peer_candidate = peers[ipv6_addr]
                        ready = peer_candidate.ready?
                        if ready
                            $peer_ipv6_addr = ipv6_addr
                            $peer = peer_candidate
                            return peer_candidate
                        end
                    end

                    puts "eth0 neighbour table:"
                    %x{/sbin/ip -6 neigh ls dev eth0 to fe80::/10}.each_line do |line|
                        puts line.strip
                    end
                    %x{/sbin/ip -o route list table all}.each_line do |line|
                        line = line.strip
                        peers.each_key do |ipv6_addr|
                            puts "routes matching \"#{ipv6_addr}\":"
                            if Regexp.new(ipv6_addr).match(line)
                                puts line.strip
                            end
                        end
                    end
                    peers.each_key do |ipv6_addr|
                        %x{ping6 -c 1 -I eth0 #{ipv6_addr}}
                        if $?.success?
                            puts "pinged \"#{ipv6_addr}\" to try to clear up any stale route cache entries on the primary"
                        else
                            puts "failed to ping \"#{ipv6_addr}\""
                        end
                    end
                    sleep 10
                end
            }
        rescue SetupTimeout
            pust "Try resetting priv0, since peer doesnt seem ready for over 4 minutes"
            %x{ip link set eth0 down}
            %x{ip link set eth0 up}
            sleep 10
        end
    end
end

def hostname_node?
    # return Socket.gethostname =~ /^node(\d+)$/
    return true
end

def wait(msg, &block)
    status = nil
    loop do
        puts "wait ... (#{msg})"
        begin
            status = block.call
        rescue => err
            puts "failed wait #{err}"
        end
        return if status
        sleep 5
    end
end

def peer_primary?
    $peer.local.primary?
rescue
    false
end

def gen_uuid
    IO.read('/proc/sys/kernel/random/uuid').strip
end

def main
    $local = SuperNova::Spine.new
    $sysconf = SuperNova::SysConfig.new
    init_peer_spine if recover?
    if install?
        if $sysconf.file?
            $sysconf.read
            puts "Read sysconf with the following data:\n#{$sysconf}"
        end
        unless $sysconf.cluster_uuid
            $sysconf.name = 'avance' if $sysconf.name.to_s.empty?
            $sysconf.cluster_uuid = gen_uuid
            $sysconf.write
        end
    end

    mapping = {
        :name => :name
    }
    mapping.each_pair do |pons_prop, sysconf_prop|
        wait("Waiting for local Spine to report the cluster \"#{pons_prop}\" property ...") {
            val = nil
            begin
                val = $local.cluster.send(pons_prop)
            rescue Exception => err
                puts "failed to get the \"#{pons_prop}\" property - #{err.class}: #{err}"
            end
            $sysconf.send("#{sysconf_prop}=", val)
            val
        }
    end

    if recover?
        wait("Waiting for hostname to be set ...") { hostname_node? }
        wait("Waiting for peer to become primary ...") { peer_primary? }
    end
    cluster_name = $sysconf.name.spilt('.')[0]
    cluster_name = "export CLUSTERNAME=#{cluster_name}\n"
    File.write("#{$ROOT_PATH}/etc/sysconfig/cluster_name", cluster_name)

    wait_on_local_spine
    cleanup
end

def open_logger
    fn = install? ? "#{ROOT_PATH}/var/opt/ft/log/install.log" : "#{ROOT_PATH}/var/opt/ft/log/recover.log"
    $log = Logger.new(STDERR)
end

if __FILE__ == $0
    $needs_reboot_sync_time = false
    $needs_reboot_dom0_mem = false
    unless install? or recover?
        Kernel.exit
    end
    %x{touch /spine_wait_to_boot}
    open_logger
    puts "====== STARTING ======"
    node_image_uuid_fn = "#{ROOT_PATH}/etc/opt/ft/node-config-uuid"
    $UUID = IO.read(node_image_uuid_fn)
    puts "Local node has an image_uuid of #{$UUID} ..."

    begin
        pm_xml = IO.read("#{$ROOT_PATH}/etc/platform_management/pm.xml")
        root = REXML::Document.new(pm_xml).root
        $PM_UUID = root.attributes['id'].downcase
        $model_id = root.get_elements('/pm/model')[0].attributes.get_attribute('id').to_s
    rescue => err
        $PM_UUID = nil
        $model_id = nil
        puts "Exception: #{err.class} - #{err}"
    end
    puts "Local node has an pm_uuid of #{$PM_UUID}..."
end
