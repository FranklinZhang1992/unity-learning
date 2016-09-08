#!/usr/bin/ruby
#==================================================
# Necessary folders:
# /tmp/spine
#==================================================

$HOME_PATH = ENV['HOME']
$ROOT_PATH = "/tmp/spine"
$INSTALL = ARGV[0].to_s.chomp
$:.unshift($INSTALL)
$0 = '[spine]'
$debug = 0
$force_shuntdown = false
$config = "#{$ROOT_PATH}/etc/opt/ft/spine"
$SPOOL = "#{$ROOT_PATH}/var/spool"
$log_dir = "#{$ROOT_PATH}/var/opt/ft/log"
$SYSCONFIG = "#{$ROOT_PATH}/etc/sysconfig/spine"

require 'securerandom'
require 'thread'
require 'singleton'
require 'fileutils'
require 'base/extensions'
require 'base/logging'
require 'supernova/dendrite'
require 'install/repository'
require 'supernova/pons'
require 'net/webdav'
require 'supernova/node'
require 'supernova/domain/service'
require 'supernova/node/service'
require 'supernova/service'
require 'supernova/domain'

class Main
    include Singleton

    def load_sysconfig
        begin
            IO.read($SYSCONFIG).each_line do |line|
                key, value = line.strip.split('=')
                case key
                when 'UUID';
                    $UUID = value
                    logInfo {"Node installation UUID id #{$UUID}"}
                when 'PM_UUID';
                    $PM_UUID = value
                    logInfo {"Physical machine UUID is #{$PM_UUID}"}
                end
            end
        rescue Exception => e
            logError {"failed to read system config: #{e}"}
        end
        if $UUID.nil?
            logWarning {"No node installation UUID was found in #{$SYSCONFIG}"}
            Kernel.exit
        end
        if $PM_UUID.nil?
            logWarning {"No physical server UUID was found in #{$SYSCONFIG}"}
            Kernel.exit
        end
        unless /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/.match($UUID)
            logWarning {"System UUID is not well formed #{$UUID}"}
            Kernel.exit
        end
    end

    def restart(signal=nil)
        logNotice {"Received: #{signal}"} unless signal.nil?
        logNotice {" ======= SPINE RESTART STARTED ======="}
        begin
            SuperNova.pons.stop
            trap(34,"IGNORE")
            SuperNova::Service.each { |service|
                logDebug {"Shutdown service #{service.class.to_s}"}
                service.stop
            }
        rescue Exception => exception
            logWarning {"shutting down => #{exception}"}
            Kernel.exit
        end
        logNotice {"Shutdown: killing other threads"}
        Thread.list.each { |thread|
            logInfo {"Thread: stopping thread '#{thread['name'].to_s}' in state #{thread.status}"}
            next if thread == Thread.main
            thread.exit
        }
        logNotice {" ======= SPINE RESTART ======="}
        Kernel.exit
    end

    def shutdown(signal = nil)
        logNotice { "Received: #{signal}" } unless signal.nil?
        logNotice { "====== SPINE SHUTDOWN STARTED ======" }
        SuperNova.pons.stop
        SuperNova.dendrite.ignore!
        SuperNova.dendrite.stop
        SuperNova::Service.each { |service|
            logDebug {"Shutdown service #{service.class.to_s}"}
            service.stop
        }
        $force_shuntdown = true
        logNotice { "====== SPINE SHUTDOWN COMPLETE ======" }
    end

    def boot_services
        begin
            SuperNova.gatekeeper.boot
            SuperNova.pons.boot
            SuperNova.nodes.boot

            SuperNova.domains.boot
            logDebug {"=== Services booted ==="}
        rescue Exception => e
            logWarning {"Exception[boot_services] => #{e}"}
        end
    end

    def start_local_services
        begin
            SuperNova.pons.start
            SuperNova.dendrite.start
            SuperNova.nodes.start
            logDebug {"=== Local services started ==="}
        rescue Exception => e
            logWarning {"Exception[start_local_services] => #{e}"}
        end
    end

    def start_shared_services
        logDebug {"=== Starting shared service ==="}
        SuperNova.domains.start
        logDebug {"=== Shared services started ==="}
    end

    def boot_thread
        logDebug { "Booting thread for Pons" }
        SuperNova.pons.boot_thread
        logDebug { "Thread for Pons is running" }
    end

    def start
        load_sysconfig
        logDebug {"STARTUP: boot services"}
        boot_services
        logDebug {"STARTUP: start local services"}
        start_local_services
        trap("HUP")  { restart('HUP') }
        trap("QUIT") { restart('QUIT') }
        trap("INT") { shutdown('INT')}
        trap("TERM") { shutdown('TERM')}
        logDebug {"STARTUP: traps initialized"}

        logDebug {"STARTUP: joining a cell"}
        while !SuperNova.node.config.cell_uuid
            logNotice {"waiting to join a cell..."}
            sleep 3

            SuperNova.node.primary? and
                logError { "How could this node be primary?!  It hasn\'t joined a cluster yet?!" }

            SuperNova.nodes.config.each do |config|
                next if config.uuid == $UUID or config.locked or config.cell_uuid.nil?
                begin
                    services = SuperNova::PhantomServices.new(config)
                    invitation = services['GateKeeper'].introduce($UUID)
                    SuperNova.node.accept_invitation(invitation)
                rescue Exception => err
                    case err
                    when Errno::ECONNREFUSED, Errno::ECONNRESET
                        logInfo {"unable to connect to spine on #{config.hostname}, #{err}"}
                    when Errno::EHOSTUNREACH, Errno::ENETUNREACH
                        logInfo {"unable to connect to node #{config.hostname}, #{err}"}
                    when SuperNova::NodeUnreachable
                        logNotice {"node #{config.hostname} is unreachable"}
                    when Errno::EAGAIN
                        logNotice {"introduce failed, retry later: #{err}"}
                    when Timeout::Error
                        logNotice {"introduce request to #{config.hostname} timed out, #{err}"}
                    else
                        logException("introduce request to #{config.hostname} failed", err)
                    end
                else
                    logNotice {"successfully joined a cell/cluster, sleeping while my hostname change to #{SuperNova.node.hostname} takes effect"}
                    sleep 45
                end
            end
        end

        start_shared_services

        logNotice {"====== SPINE STARTUP COMPLETE ======"}
    end
end

def precondition_check
    if !File.exist?($SYSCONFIG)
        logWarning {"cannot find config file #{$SYSCONFIG}"}
        Kernel.exit
    end
end

def do_clean
    logDebug("SPINE") { "Clean folders" }
    # %x{rm -rf #{$config}/*}
    %x{rm -rf #{$SPOOL}/hoard/*}
    %x{rm -rf #{$log_dir}/*}
end

def wait_for_sub_threads
    while Thread.list.size != 1 && $force_shuntdown == false
        sleep 1
    end
end

begin
    precondition_check
    # do_clean
    Main.instance.start
    wait_for_sub_threads
rescue Exception => exception
    logNotice {"====== SPINE STARTUP EXCEPTION ======"}
    logWarning("SPINE") { "Start spine failed => #{exception}" }
    p exception
end
