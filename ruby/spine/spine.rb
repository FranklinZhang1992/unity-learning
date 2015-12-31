#!/usr/bin/ruby
#==================================================
# Necessary folders:
# /tmp/spine
#==================================================

$HOME_PATH = ENV['HOME']
$ROOT_PATH = "/tmp/spine"
$INSTALL = "#{$HOME_PATH}/workspace/unity-learning/ruby/spine"
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
            SuperNova.pons.boot
            SuperNova.domains.boot
            SuperNova.nodes.boot
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
        boot_services
        start_local_services
        trap("HUP")  { restart('HUP') }
        trap("QUIT") { restart('QUIT') }
        trap("INT") { shutdown('INT')}
        trap("TERM") { shutdown('TERM')}

        logDebug {"STARTUP: traps initialized"}
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
