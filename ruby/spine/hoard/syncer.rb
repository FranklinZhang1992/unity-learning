require 'singleton'
require 'thread'
require 'monitor'
require 'fileutils'

begin
    FileUtils::mkdir_p("#{$SPOOL}/hoard")
rescue Exception => exception
    logWarning {"failed to create folder for syncer => #{exception}"}
end

class HoardTransactionEntry
    attr :path
    def initialize(path)
        @path = path
    end
    def write
        File.open(transaction, 'a') { |o| o.puts @path}
    end
end

class HoardCreate < HoardTransactionEntry
    def transaction()
        "#{$SPOOL}/hoard/creates"
    end
end

class HoardUpdate < HoardTransactionEntry
    def transaction()
        "#{$SPOOL}/hoard/updates"
    end
end

class HoardDelete < HoardTransactionEntry
    def transaction()
        "#{$SPOOL}/hoard/deletes"
    end
end

class Syncer
    include Singleton
    def initialize
        @queue = {
            :creates => Queue.new,
            :updates => Queue.new,
            :deletes => Queue.new
        }
        @restarts = 0
        @ready = false
    end
    def ready?
        @ready
    end
    def self.create(path)
        Syncer.instance.enqueue_create(path)
    end
    def enqueue_create(path)
        @queue[:creates].push(HoardCreate.new(path))
        @thread.wakeup
        nil
    end
    def self.add(path)
        Syncer.instance.enqueue_update(path)
    end
    def enqueue_update(path)
        @queue[:updates].push(HoardUpdate.new(path))
        @thread.wakeup
        nil
    end
    def self.delete(path)
        Syncer.instance.enqueue_delete(path)
    end
    def enqueue_delete(path)
        @queue[:deletes].push(HoardDelete.new(path))
        @thread.wakeup
        nil
    end 
    def process
        [:updates, :creates, :deletes].each do |type|
            queue = @queue[type]
            queue.pop.write until queue.empty?
        end
        Thread.stop
    end

    def start
        @thread = Thread.new do
            @ready = true
            begin
                logDebug { "Syncer started successfully" }
                loop {process}
            rescue Exception => exception
                p exception
                @restarts += 1
                sleep 2
                retry
            end
        end
        sleep(1) until ready?
    end

    def stop
        @thread.exit
    end
end

Syncer.instance.start
